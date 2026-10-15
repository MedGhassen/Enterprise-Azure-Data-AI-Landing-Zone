# Resource group for the landing zone (shared by most resources)
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}-${local.instance_suffix}"
  location = var.primary_region
  tags     = local.common_tags
}

# ---------------------------------------------------------------------------
# Governance
# ---------------------------------------------------------------------------
module "governance" {
  source = "./modules/governance"

  project_name                      = var.project_name
  environment                       = var.environment
  tags                              = local.common_tags
  create_management_group_hierarchy = true
  subscription_id                   = var.subscription_id
  allowed_locations                 = [var.primary_region]

  create_identity_management_group = var.create_identity_management_group
  subscription_id_connectivity     = var.subscription_id_connectivity
  subscription_id_management       = var.subscription_id_management
  subscription_id_identity         = var.subscription_id_identity
  subscription_id_dataai_dev       = var.subscription_id_dataai_dev
  subscription_id_dataai_staging   = var.subscription_id_dataai_staging
  subscription_id_dataai_prod      = var.subscription_id_dataai_prod
  subscription_id_sandbox          = var.subscription_id_sandbox

  enable_iso27001                       = var.enable_iso27001
  enable_nis2                           = var.enable_nis2
  nis2_initiative_id                    = var.nis2_initiative_id
  compliance_policy_scope_mg            = var.compliance_policy_scope_mg
  compliance_policy_parameters_iso27001 = var.compliance_policy_parameters_iso27001
  compliance_policy_parameters_nis2     = var.compliance_policy_parameters_nis2
  compliance_policy_assignments         = var.compliance_policy_assignments
}

# ---------------------------------------------------------------------------
# Networking (hub-spoke, firewall, private DNS zones, NSGs)
# ---------------------------------------------------------------------------
module "networking" {
  source = "./modules/networking"

  project_name                = var.project_name
  environment                 = var.environment
  primary_region              = var.primary_region
  name_prefix                 = local.name_prefix
  name_suffix                 = local.name_suffix
  tags                        = local.common_tags
  resource_group_name         = azurerm_resource_group.main.name
  enable_bastion              = var.enable_bastion
  enable_gateway              = var.enable_vpn_gateway
  vpn_client_address_pool     = var.vpn_client_address_pool
  log_analytics_workspace_id  = "" # set after monitoring
  flow_log_storage_account_id = "" # set after data_lake if desired
}

# ---------------------------------------------------------------------------
# Monitoring (Log Analytics, App Insights, Action Group)
# ---------------------------------------------------------------------------
module "monitoring" {
  source = "./modules/monitoring"

  project_name        = var.project_name
  environment         = var.environment
  primary_region      = var.primary_region
  name_prefix         = local.name_prefix
  name_suffix         = local.name_suffix
  tags                = local.common_tags
  resource_group_name = azurerm_resource_group.main.name
  log_retention_days  = var.environment == "prod" ? 365 : 90
  action_group_emails = [var.owner_email]
}

# ---------------------------------------------------------------------------
# Security (Key Vault, Defender for Cloud)
# ---------------------------------------------------------------------------
module "security" {
  source = "./modules/security"

  project_name                = var.project_name
  environment                 = var.environment
  primary_region              = var.primary_region
  name_prefix                 = local.name_prefix
  name_suffix                 = local.name_suffix
  tags                        = local.common_tags
  resource_group_name         = azurerm_resource_group.main.name
  subnet_id_private_endpoint  = module.networking.subnet_ids["snet_security"]
  log_analytics_workspace_id  = module.monitoring.log_analytics_workspace_id
  defender_contact_email      = var.owner_email
  private_dns_zone_vault_name = "privatelink.vaultcore.azure.net"
  private_dns_zone_vault_rg   = azurerm_resource_group.main.name
}

# ---------------------------------------------------------------------------
# Data Lake (ADLS Gen2, medallion, private endpoints)
# ---------------------------------------------------------------------------
module "data_lake" {
  source = "./modules/data_lake"

  project_name               = var.project_name
  environment                = var.environment
  primary_region             = var.primary_region
  name_prefix                = local.name_prefix
  name_suffix                = local.name_suffix
  tags                       = local.common_tags
  resource_group_name        = azurerm_resource_group.main.name
  subnet_id_private_endpoint = module.networking.subnet_ids["snet_data"]
  private_dns_zone_blob_name = "privatelink.blob.core.windows.net"
  private_dns_zone_blob_rg   = azurerm_resource_group.main.name
  private_dns_zone_dfs_name  = "privatelink.dfs.core.windows.net"
  private_dns_zone_dfs_rg    = azurerm_resource_group.main.name
}

# ---------------------------------------------------------------------------
# Data Factory (managed VNet, managed PEs to storage/SQL/Synapse)
# ---------------------------------------------------------------------------
module "data_factory" {
  source = "./modules/data_factory"

  project_name                     = var.project_name
  environment                      = var.environment
  primary_region                   = var.primary_region
  name_prefix                      = local.name_prefix
  name_suffix                      = local.name_suffix
  tags                             = local.common_tags
  resource_group_name              = azurerm_resource_group.main.name
  log_analytics_workspace_id       = module.monitoring.log_analytics_workspace_id
  git_repo_type                    = var.adf_repo_config.type
  git_repo_url                     = var.adf_repo_config.repo_url
  git_branch                       = var.adf_repo_config.branch
  git_root_folder                  = var.adf_repo_config.root_folder
  managed_private_endpoint_targets = [
    { name = "storage-dfs", target_resource_id = module.data_lake.storage_account_id, subresource_name = "dfs" }
  ]
}

# ---------------------------------------------------------------------------
# Databricks (VNet injection, Unity Catalog optional, private endpoint)
# ---------------------------------------------------------------------------
module "databricks" {
  source = "./modules/databricks"

  project_name                     = var.project_name
  environment                      = var.environment
  primary_region                   = var.primary_region
  name_prefix                      = local.name_prefix
  name_suffix                      = local.name_suffix
  tags                             = local.common_tags
  resource_group_name              = azurerm_resource_group.main.name
  subnet_id_private                = module.networking.subnet_ids["snet_databricks_private"]
  subnet_id_public                 = module.networking.subnet_ids["snet_databricks_public"]
  subnet_id_private_endpoint       = module.networking.subnet_ids["snet_data"]
  nsg_association_id_public        = module.networking.nsg_association_ids["databricks_public"]
  nsg_association_id_private       = module.networking.nsg_association_ids["databricks_private"]
  no_public_ip                     = true
  storage_account_name             = module.data_lake.storage_account_name
  private_dns_zone_databricks_name = "privatelink.azuredatabricks.net"
  private_dns_zone_databricks_rg   = azurerm_resource_group.main.name
}

# ---------------------------------------------------------------------------
# Synapse (workspace, SQL pool, Spark pool, managed PE to ADLS)
# ---------------------------------------------------------------------------
module "synapse" {
  source = "./modules/synapse"

  project_name               = var.project_name
  environment                = var.environment
  primary_region             = var.primary_region
  name_prefix                = local.name_prefix
  name_suffix                = local.name_suffix
  tags                       = local.common_tags
  resource_group_name        = azurerm_resource_group.main.name
  storage_account_id         = module.data_lake.storage_account_id
  storage_account_name       = module.data_lake.storage_account_name
  data_lake_filesystem_name  = "curated"
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  subnet_id_private_endpoint = module.networking.subnet_ids["snet_data"]
  private_dns_zone_sql_name  = "privatelink.sql.azuresynapse.net"
  private_dns_zone_sql_rg    = azurerm_resource_group.main.name
}

# ---------------------------------------------------------------------------
# Databases (Azure SQL, Cosmos DB)
# ---------------------------------------------------------------------------
module "databases" {
  source = "./modules/databases"

  project_name                 = var.project_name
  environment                  = var.environment
  primary_region               = var.primary_region
  name_prefix                  = local.name_prefix
  name_suffix                  = local.name_suffix
  tags                         = local.common_tags
  resource_group_name          = azurerm_resource_group.main.name
  subnet_id_sql_pe             = module.networking.subnet_ids["snet_data"]
  subnet_id_cosmos_pe          = module.networking.subnet_ids["snet_data"]
  log_analytics_workspace_id   = module.monitoring.log_analytics_workspace_id
  private_dns_zone_sql_name    = "privatelink.database.windows.net"
  private_dns_zone_sql_rg      = azurerm_resource_group.main.name
  cosmos_locations             = var.environment == "prod" ? [{ location = var.primary_region, failover_priority = 0 }] : []
  private_dns_zone_cosmos_name = "privatelink.documents.azure.net"
  private_dns_zone_cosmos_rg   = azurerm_resource_group.main.name
}

# ---------------------------------------------------------------------------
# Streaming (Event Hubs, Stream Analytics)
# ---------------------------------------------------------------------------
module "streaming" {
  source = "./modules/streaming"

  project_name                   = var.project_name
  environment                    = var.environment
  primary_region                 = var.primary_region
  name_prefix                    = local.name_prefix
  name_suffix                    = local.name_suffix
  tags                           = local.common_tags
  resource_group_name            = azurerm_resource_group.main.name
  capture_storage_account_id     = module.data_lake.storage_account_id
  subnet_id_private_endpoint     = module.networking.subnet_ids["snet_data"]
  private_dns_zone_eventhub_name = "privatelink.eventhub.azure.net"
  private_dns_zone_eventhub_rg   = azurerm_resource_group.main.name
  log_analytics_workspace_id     = module.monitoring.log_analytics_workspace_id
}

# ---------------------------------------------------------------------------
# AI/ML (ML workspace, AI Foundry Hub + Projects, OpenAI, Cognitive, AI Search)
# ---------------------------------------------------------------------------
module "ai_ml" {
  source = "./modules/ai_ml"

  project_name               = var.project_name
  environment                = var.environment
  primary_region             = var.primary_region
  name_prefix                = local.name_prefix
  name_suffix                = local.name_suffix
  tags                       = local.common_tags
  resource_group_name        = azurerm_resource_group.main.name
  subnet_id_ai               = module.networking.subnet_ids["snet_ai"]
  key_vault_id               = module.security.key_vault_id
  storage_account_id         = module.data_lake.storage_account_id
  application_insights_id    = module.monitoring.application_insights_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  vnet_subnet_id_openai      = module.networking.subnet_ids["snet_ai"]
  dns_zone_aml_name          = "privatelink.api.azureml.ms"
  dns_zone_aml_rg            = azurerm_resource_group.main.name
  dns_zone_openai_name       = "privatelink.openai.azure.com"
  dns_zone_openai_rg         = azurerm_resource_group.main.name
  dns_zone_cognitive_name    = "privatelink.cognitiveservices.azure.com"
  dns_zone_cognitive_rg      = azurerm_resource_group.main.name
  dns_zone_search_name       = "privatelink.search.windows.net"
  dns_zone_search_rg         = azurerm_resource_group.main.name
  openai_deployments = [
    { name = "gpt4o", model = "gpt-4o", version = "2024-08-06", capacity = 10 },
    { name = "gpt4o-mini", model = "gpt-4o-mini", version = "2024-07-18", capacity = 20 }
  ]
  ai_foundry_projects = [
    { name = "main", display_name = "Main Project" }
  ]
}

# ---------------------------------------------------------------------------
# Serving (AKS, ACR, optional Purview)
# ---------------------------------------------------------------------------
module "serving" {
  source = "./modules/serving"

  project_name               = var.project_name
  environment                = var.environment
  primary_region             = var.primary_region
  name_prefix                = local.name_prefix
  name_suffix                = local.name_suffix
  tags                       = local.common_tags
  resource_group_name        = azurerm_resource_group.main.name
  subnet_id_aks              = module.networking.subnet_ids["snet_serving"]
  subnet_id_acr_pe           = module.networking.subnet_ids["snet_serving"]
  enable_purview             = var.enable_purview
  private_dns_zone_acr_name  = "privatelink.azurecr.io"
  private_dns_zone_acr_rg    = azurerm_resource_group.main.name
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
}
