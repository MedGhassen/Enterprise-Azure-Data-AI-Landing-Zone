data "azurerm_client_config" "current" {}

# Azure SQL logical server
resource "azurerm_mssql_server" "main" {
  name                          = "${var.name_prefix}-sql-${var.name_suffix}"
  resource_group_name           = var.resource_group_name
  location                      = var.primary_region
  version                       = var.sql_server_version
  administrator_login           = "sqladmin"
  administrator_login_password  = random_password.sql.result
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  tags                          = var.tags

  dynamic "azuread_administrator" {
    for_each = length(var.aad_admin_object_ids) > 0 ? [1] : []
    content {
      login_username = "Azure AD Admin"
      object_id      = var.aad_admin_object_ids[0]
      tenant_id      = data.azurerm_client_config.current.tenant_id
    }
  }
}

resource "random_password" "sql" {
  length  = 24
  special = true
}

# SQL firewall: default deny (no rules = deny all; we use PE only)
# Private endpoint for SQL
resource "azurerm_private_endpoint" "sql" {
  name                = "${var.name_prefix}-sql-pe-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_sql_pe
  tags                = var.tags

  private_service_connection {
    name                           = "sql-psc"
    private_connection_resource_id = azurerm_mssql_server.main.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_a_record" "sql" {
  count               = var.private_dns_zone_sql_name != "" && var.private_dns_zone_sql_rg != "" ? 1 : 0
  name                = azurerm_mssql_server.main.name
  zone_name           = var.private_dns_zone_sql_name
  resource_group_name = var.private_dns_zone_sql_rg
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql.private_service_connection[0].private_ip_address]
}

# SQL database(s)
resource "azurerm_mssql_database" "main" {
  name      = "sqldb"
  server_id = azurerm_mssql_server.main.id
  sku_name  = var.sql_database_sku
  collation = "SQL_Latin1_General_CP1_CI_AS"
  tags      = var.tags

  transparent_data_encryption_enabled = true
}

# SQL audit to Log Analytics via diagnostic setting
resource "azurerm_monitor_diagnostic_setting" "sql" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "sql-audit-diag"
  target_resource_id         = azurerm_mssql_database.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log {
    category = "SQLInsights"
  }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Cosmos DB (optional - when locations provided)
resource "azurerm_cosmosdb_account" "main" {
  count               = length(var.cosmos_locations) > 0 ? 1 : 0
  name                = "${var.name_prefix}-cosmos-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  tags                = var.tags

  consistency_policy {
    consistency_level = var.cosmos_consistency_level
  }

  dynamic "geo_location" {
    for_each = var.cosmos_locations
    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
    }
  }

  public_network_access_enabled = false

  dynamic "virtual_network_rule" {
    for_each = [] # VNet rules optional when using PE
    content {}
  }
}

resource "azurerm_cosmosdb_sql_database" "main" {
  count               = length(var.cosmos_locations) > 0 ? 1 : 0
  name                = "db"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main[0].name
}

resource "azurerm_cosmosdb_sql_container" "main" {
  count               = length(var.cosmos_locations) > 0 ? 1 : 0
  name                = "container"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main[0].name
  database_name       = azurerm_cosmosdb_sql_database.main[0].name
  partition_key_path  = "/id"
  throughput          = var.cosmos_enable_autoscale ? null : 400
  dynamic "autoscale_settings" {
    for_each = var.cosmos_enable_autoscale ? [1] : []
    content {
      max_throughput = var.cosmos_autoscale_max_throughput
    }
  }
}

resource "azurerm_private_endpoint" "cosmos" {
  count               = length(var.cosmos_locations) > 0 ? 1 : 0
  name                = "${var.name_prefix}-cosmos-pe-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_cosmos_pe
  tags                = var.tags

  private_service_connection {
    name                           = "cosmos-psc"
    private_connection_resource_id = azurerm_cosmosdb_account.main[0].id
    subresource_names              = ["Sql"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_a_record" "cosmos" {
  count               = length(var.cosmos_locations) > 0 && var.private_dns_zone_cosmos_name != "" && var.private_dns_zone_cosmos_rg != "" ? 1 : 0
  name                = azurerm_cosmosdb_account.main[0].name
  zone_name           = var.private_dns_zone_cosmos_name
  resource_group_name = var.private_dns_zone_cosmos_rg
  ttl                 = 300
  records             = [azurerm_private_endpoint.cosmos[0].private_service_connection[0].private_ip_address]
}
