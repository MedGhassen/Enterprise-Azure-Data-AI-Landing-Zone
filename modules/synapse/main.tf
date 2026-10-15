data "azurerm_client_config" "current" {}

resource "random_password" "sql" {
  count   = var.sql_admin_password == "" ? 1 : 0
  length  = 24
  special = true
}

locals {
  sql_password = var.sql_admin_password != "" ? var.sql_admin_password : random_password.sql[0].result
}

resource "azurerm_synapse_workspace" "main" {
  name                                 = "${var.name_prefix}-syn-${var.name_suffix}"
  resource_group_name                  = var.resource_group_name
  location                             = var.primary_region
  storage_data_lake_gen2_filesystem_id = "https://${var.storage_account_name}.dfs.core.windows.net/${var.data_lake_filesystem_name}"
  sql_administrator_login              = var.sql_admin_login != "" ? var.sql_admin_login : "sqladmin"
  sql_administrator_login_password     = local.sql_password
  managed_virtual_network_enabled      = true
  public_network_access_enabled        = false
  tags                                 = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_synapse_workspace_sql_aad_admin" "main" {
  count                = length(var.aad_admin_object_ids) > 0 ? 1 : 0
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  login                = "Azure AD Admin"
  object_id            = var.aad_admin_object_ids[0]
  tenant_id            = data.azurerm_client_config.current.tenant_id
}

# Firewall rules cannot be managed when public_network_access_enabled = false.
# Azure services connect via the managed VNet + managed private endpoints.

# Dedicated SQL pool
resource "azurerm_synapse_sql_pool" "main" {
  name                 = "sqlpool"
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  sku_name             = var.sql_pool_sku
  create_mode          = "Default"
  collation            = var.sql_collation
  tags                 = var.tags
}

# Spark pool
resource "azurerm_synapse_spark_pool" "main" {
  name                 = "sparkpool"
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  node_size_family     = "MemoryOptimized"
  node_size            = var.spark_node_size
  auto_scale {
    min_node_count = var.spark_pool_min_nodes
    max_node_count = var.spark_pool_max_nodes
  }
  auto_pause {
    delay_in_minutes = var.spark_pool_auto_pause_delay
  }
  spark_version = var.spark_version
  tags          = var.tags
}

# Managed private endpoints require public network access or a private connection to
# the Synapse control plane. Provision these via Synapse Studio after connecting
# through VPN/private endpoint, or temporarily enable public access.

# Diagnostics
resource "azurerm_monitor_diagnostic_setting" "synapse" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "synapse-diag"
  target_resource_id         = azurerm_synapse_workspace.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log { category = "SynapseRbacOperations" }
  enabled_log { category = "GatewayApiRequests" }
  enabled_log { category = "SQLSecurityAuditEvents" }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Private endpoints for Synapse (workspace has public_network_access_enabled = false so we need PE for connectivity)
# Optional: create PE for sql, dev, azuresynapse when subnet and DNS zones provided
resource "azurerm_private_endpoint" "synapse_sql" {
  count               = var.enable_private_endpoint && var.private_dns_zone_sql_name != "" ? 1 : 0
  name                = "${var.name_prefix}-syn-sql-pe-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_private_endpoint
  tags                = var.tags

  private_service_connection {
    name                           = "syn-sql-psc"
    private_connection_resource_id = azurerm_synapse_workspace.main.id
    subresource_names              = ["Sql"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_a_record" "synapse_sql" {
  count               = var.enable_private_endpoint && var.private_dns_zone_sql_name != "" && var.private_dns_zone_sql_rg != "" ? 1 : 0
  name                = azurerm_synapse_workspace.main.name
  zone_name           = var.private_dns_zone_sql_name
  resource_group_name = var.private_dns_zone_sql_rg
  ttl                 = 300
  records             = [azurerm_private_endpoint.synapse_sql[0].private_service_connection[0].private_ip_address]
}
