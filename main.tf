# Data & AI landing zone (one deployment per environment).
# Tenant-level governance (management groups, policy, custom roles) lives in ./platform.

resource "azurerm_resource_group" "this" {
  for_each = local.resource_groups
  name     = each.value
  location = local.location
  tags     = local.common_tags
}

resource "azurerm_management_lock" "rg" {
  for_each   = var.enable_resource_locks ? azurerm_resource_group.this : {}
  name       = "do-not-delete"
  scope      = each.value.id
  lock_level = "CanNotDelete"
  notes      = "Managed by Terraform. Remove enable_resource_locks before destroying."
}

# ---------------------------------------------------------------------------
# Foundation
# ---------------------------------------------------------------------------
module "monitoring" {
  source = "./modules/monitoring"

  name_prefix              = local.name_prefix
  name_suffix              = local.name_suffix
  location                 = local.location
  location_display_name    = local.region.display
  resource_group_name      = azurerm_resource_group.this["shared"].name
  tags                     = local.common_tags
  log_retention_days       = var.log_retention_days
  daily_quota_gb           = var.log_daily_quota_gb
  action_group_emails      = [var.owner_email]
  action_group_webhook_url = var.alert_webhook_url
}

module "networking" {
  source = "./modules/networking"

  name_prefix                  = local.name_prefix
  name_suffix                  = local.name_suffix
  unique_suffix                = local.unique_suffix
  location                     = local.location
  resource_group_name          = azurerm_resource_group.this["network"].name
  tags                         = local.common_tags
  availability_zones           = var.availability_zones
  hub_vnet_address_space       = var.hub_vnet_address_space
  spoke_vnet_address_space     = var.spoke_vnet_address_space
  subnet_cidrs                 = var.subnet_cidrs
  enable_firewall              = var.enable_firewall
  firewall_sku                 = var.firewall_sku
  firewall_threat_intel_mode   = var.firewall_threat_intel_mode
  enable_bastion               = var.enable_bastion
  enable_vpn_gateway           = var.enable_vpn_gateway
  vpn_gateway_sku              = var.vpn_gateway_sku
  vpn_client_address_pool      = var.vpn_client_address_pool
  enable_nat_gateway           = var.enable_databricks
  enable_flow_logs             = var.enable_flow_logs
  log_analytics_workspace_id   = module.monitoring.log_analytics_workspace_id
  log_analytics_workspace_guid = module.monitoring.log_analytics_workspace_guid
}

module "security" {
  source = "./modules/security"

  name_prefix                = local.name_prefix
  name_suffix                = local.name_suffix
  unique_suffix              = local.unique_suffix
  location                   = local.location
  resource_group_name        = azurerm_resource_group.this["shared"].name
  tags                       = local.common_tags
  private_endpoint_subnet_id = module.networking.subnet_ids["security"]
  private_dns_zone_ids       = module.networking.private_dns_zone_ids
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  purge_protection_enabled   = var.key_vault_purge_protection
  enable_defender            = var.enable_defender
  defender_plans             = var.defender_plans
  defender_contact_email     = var.owner_email
}

# ---------------------------------------------------------------------------
# Data platform
# ---------------------------------------------------------------------------
module "data_lake" {
  source = "./modules/data_lake"

  name_prefix                = local.name_prefix
  name_suffix                = local.name_suffix
  unique_suffix              = local.unique_suffix
  location                   = local.location
  resource_group_name        = azurerm_resource_group.this["data"].name
  tags                       = local.common_tags
  replication                = var.data_lake_replication
  private_endpoint_subnet_id = module.networking.subnet_ids["data"]
  private_dns_zone_ids       = module.networking.private_dns_zone_ids
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
}

module "data_factory" {
  source = "./modules/data_factory"
  count  = var.enable_data_factory ? 1 : 0

  name_prefix                = local.name_prefix
  name_suffix                = local.name_suffix
  unique_suffix              = local.unique_suffix
  location                   = local.location
  resource_group_name        = azurerm_resource_group.this["data"].name
  tags                       = local.common_tags
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  storage_account_id         = module.data_lake.storage_account_id
  private_endpoint_subnet_id = module.networking.subnet_ids["data"]
  private_dns_zone_ids       = module.networking.private_dns_zone_ids
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  git_repo_type              = try(var.adf_git.type, "GitHub")
  git_repo_url               = try(var.adf_git.repo_url, null)
  git_branch                 = try(var.adf_git.branch, "main")
  git_root_folder            = try(var.adf_git.root_folder, "/")
}

module "databricks" {
  source = "./modules/databricks"
  count  = var.enable_databricks ? 1 : 0

  name_prefix                       = local.name_prefix
  name_suffix                       = local.name_suffix
  location                          = local.location
  resource_group_name               = azurerm_resource_group.this["data"].name
  tags                              = local.common_tags
  virtual_network_id                = module.networking.spoke_vnet_id
  private_subnet_name               = module.networking.subnet_names["databricks_private"]
  public_subnet_name                = module.networking.subnet_names["databricks_public"]
  private_subnet_nsg_association_id = module.networking.databricks_nsg_association_ids["databricks_private"]
  public_subnet_nsg_association_id  = module.networking.databricks_nsg_association_ids["databricks_public"]
  private_endpoint_subnet_id        = module.networking.subnet_ids["data"]
  private_dns_zone_ids              = module.networking.private_dns_zone_ids
  storage_account_id                = module.data_lake.storage_account_id
  log_analytics_workspace_id        = module.monitoring.log_analytics_workspace_id
  public_network_access_enabled     = var.databricks_public_network_access
}

module "synapse" {
  source = "./modules/synapse"
  count  = var.enable_synapse ? 1 : 0

  name_prefix                = local.name_prefix
  name_suffix                = local.name_suffix
  unique_suffix              = local.unique_suffix
  location                   = local.location
  resource_group_name        = azurerm_resource_group.this["data"].name
  tags                       = local.common_tags
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  entra_admin_object_id      = local.entra_admin_object_id
  entra_admin_login          = local.entra_admin_login
  storage_account_id         = module.data_lake.storage_account_id
  data_lake_filesystem_id    = "${module.data_lake.dfs_endpoint}synapse"
  private_endpoint_subnet_id = module.networking.subnet_ids["data"]
  private_dns_zone_ids       = module.networking.private_dns_zone_ids
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  enable_sql_pool            = var.synapse_enable_sql_pool
  sql_pool_sku               = var.synapse_sql_pool_sku

  depends_on = [module.data_lake]
}

module "databases" {
  source = "./modules/databases"
  count  = var.enable_sql_database || var.enable_cosmos_db ? 1 : 0

  name_prefix                = local.name_prefix
  name_suffix                = local.name_suffix
  unique_suffix              = local.unique_suffix
  location                   = local.location
  resource_group_name        = azurerm_resource_group.this["data"].name
  tags                       = local.common_tags
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  private_endpoint_subnet_id = module.networking.subnet_ids["data"]
  private_dns_zone_ids       = module.networking.private_dns_zone_ids
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  enable_sql                 = var.enable_sql_database
  entra_admin_object_id      = local.entra_admin_object_id
  entra_admin_login          = local.entra_admin_login
  sql_database_sku           = var.sql_database_sku
  enable_cosmos              = var.enable_cosmos_db
  cosmos_serverless          = var.cosmos_serverless
  cosmos_failover_locations  = var.cosmos_failover_locations
  cosmos_zone_redundant      = length(var.availability_zones) > 0 && !var.cosmos_serverless
}

module "streaming" {
  source = "./modules/streaming"
  count  = var.enable_event_hubs ? 1 : 0

  name_prefix                = local.name_prefix
  name_suffix                = local.name_suffix
  unique_suffix              = local.unique_suffix
  location                   = local.location
  resource_group_name        = azurerm_resource_group.this["data"].name
  tags                       = local.common_tags
  private_endpoint_subnet_id = module.networking.subnet_ids["data"]
  private_dns_zone_ids       = module.networking.private_dns_zone_ids
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  event_hubs                 = var.event_hubs
  enable_stream_analytics    = var.enable_stream_analytics
  stream_analytics_query     = var.stream_analytics_query
}

# ---------------------------------------------------------------------------
# Serving (ACR always; AKS and Purview optional)
# ---------------------------------------------------------------------------
module "serving" {
  source = "./modules/serving"

  name_prefix                  = local.name_prefix
  name_suffix                  = local.name_suffix
  unique_suffix                = local.unique_suffix
  location                     = local.location
  resource_group_name          = azurerm_resource_group.this["serving"].name
  tags                         = local.common_tags
  availability_zones           = length(var.availability_zones) > 0 ? var.availability_zones : null
  acr_zone_redundancy_enabled  = length(var.availability_zones) > 0
  private_endpoint_subnet_id   = module.networking.subnet_ids["serving"]
  private_dns_zone_ids         = module.networking.private_dns_zone_ids
  log_analytics_workspace_id   = module.monitoring.log_analytics_workspace_id
  storage_account_id           = module.data_lake.storage_account_id
  enable_aks                   = var.enable_aks
  aks_subnet_id                = module.networking.subnet_ids["serving"]
  egress_via_firewall          = var.enable_firewall
  route_table_id               = module.networking.serving_route_table_id
  aks_sku_tier                 = var.aks_sku_tier
  aks_admin_group_object_ids   = var.aks_admin_group_object_ids
  grant_deployer_cluster_admin = var.aks_grant_deployer_cluster_admin
  system_node_vm_size          = var.aks_node_vm_size
  system_node_min_count        = var.aks_system_node_count.min
  system_node_max_count        = var.aks_system_node_count.max
  user_node_vm_size            = var.aks_node_vm_size
  user_node_min_count          = var.aks_user_node_count.min
  user_node_max_count          = var.aks_user_node_count.max
  enable_purview               = var.enable_purview

  # AKS with userDefinedRouting needs the firewall rules and route in place first.
  depends_on = [module.networking]
}

# ---------------------------------------------------------------------------
# AI
# ---------------------------------------------------------------------------
module "ai" {
  source = "./modules/ai"
  count  = var.enable_foundry || var.enable_ai_search || var.enable_ml_workspace ? 1 : 0

  name_prefix                = local.name_prefix
  name_suffix                = local.name_suffix
  unique_suffix              = local.unique_suffix
  location                   = local.location
  resource_group_name        = azurerm_resource_group.this["ai"].name
  tags                       = local.common_tags
  private_endpoint_subnet_id = module.networking.subnet_ids["ai"]
  private_dns_zone_ids       = module.networking.private_dns_zone_ids
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  enable_foundry             = var.enable_foundry
  foundry_projects           = var.foundry_projects
  model_deployments          = var.model_deployments
  enable_search              = var.enable_ai_search
  search_sku                 = var.ai_search_sku
  search_replica_count       = var.ai_search_replica_count
  enable_ml_workspace        = var.enable_ml_workspace
  key_vault_id               = module.security.key_vault_id
  application_insights_id    = module.monitoring.application_insights_id
  container_registry_id      = module.serving.container_registry_id
}
