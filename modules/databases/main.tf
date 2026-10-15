# ---------------------------------------------------------------------------
# Azure SQL Database: Entra-only authentication, private endpoint, auditing to LAW
# ---------------------------------------------------------------------------
resource "azurerm_mssql_server" "main" {
  count                         = var.enable_sql ? 1 : 0
  name                          = "${var.name_prefix}-sql-${var.unique_suffix}-${var.name_suffix}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  tags                          = var.tags

  azuread_administrator {
    login_username              = var.entra_admin_login
    object_id                   = var.entra_admin_object_id
    tenant_id                   = var.tenant_id
    azuread_authentication_only = true
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_database" "main" {
  count     = var.enable_sql ? 1 : 0
  name      = "sqldb"
  server_id = azurerm_mssql_server.main[0].id
  sku_name  = var.sql_database_sku
  collation = "SQL_Latin1_General_CP1_CI_AS"
  tags      = var.tags

  transparent_data_encryption_enabled = true
}

resource "azurerm_private_endpoint" "sql" {
  count               = var.enable_sql ? 1 : 0
  name                = "${var.name_prefix}-sql-pe-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "sql-psc"
    private_connection_resource_id = azurerm_mssql_server.main[0].id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.database.windows.net"]]
  }
}

# Server-level auditing to Log Analytics (via the master database diagnostic setting).
resource "azurerm_mssql_server_extended_auditing_policy" "main" {
  count                  = var.enable_sql ? 1 : 0
  server_id              = azurerm_mssql_server.main[0].id
  log_monitoring_enabled = true
}

resource "azurerm_monitor_diagnostic_setting" "sql_audit" {
  count                      = var.enable_sql ? 1 : 0
  name                       = "audit-to-law"
  target_resource_id         = "${azurerm_mssql_server.main[0].id}/databases/master"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "SQLSecurityAuditEvents"
  }

  depends_on = [azurerm_mssql_server_extended_auditing_policy.main]
}

resource "azurerm_monitor_diagnostic_setting" "sql_db" {
  count                      = var.enable_sql ? 1 : 0
  name                       = "diag-to-law"
  target_resource_id         = azurerm_mssql_database.main[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  enabled_metric {
    category = "Basic"
  }
}

# ---------------------------------------------------------------------------
# Cosmos DB (NoSQL): Entra-only data plane, private endpoint
# ---------------------------------------------------------------------------
resource "azurerm_cosmosdb_account" "main" {
  count                         = var.enable_cosmos ? 1 : 0
  name                          = "${var.name_prefix}-cosmos-${var.unique_suffix}-${var.name_suffix}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  offer_type                    = "Standard"
  kind                          = "GlobalDocumentDB"
  public_network_access_enabled = false
  local_authentication_enabled  = false
  minimal_tls_version           = "Tls12"
  automatic_failover_enabled    = length(var.cosmos_failover_locations) > 0
  tags                          = var.tags

  consistency_policy {
    consistency_level = var.cosmos_consistency_level
  }

  geo_location {
    location          = var.location
    failover_priority = 0
    zone_redundant    = var.cosmos_zone_redundant
  }

  dynamic "geo_location" {
    for_each = var.cosmos_failover_locations
    content {
      location          = geo_location.value
      failover_priority = geo_location.key + 1
    }
  }

  dynamic "capabilities" {
    for_each = var.cosmos_serverless ? ["EnableServerless"] : []
    content {
      name = capabilities.value
    }
  }

  backup {
    type = "Continuous"
    tier = "Continuous7Days"
  }
}

resource "azurerm_cosmosdb_sql_database" "main" {
  count               = var.enable_cosmos ? 1 : 0
  name                = "db"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main[0].name
}

resource "azurerm_cosmosdb_sql_container" "main" {
  count               = var.enable_cosmos ? 1 : 0
  name                = "items"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main[0].name
  database_name       = azurerm_cosmosdb_sql_database.main[0].name
  partition_key_paths = ["/id"]

  dynamic "autoscale_settings" {
    for_each = var.cosmos_serverless ? [] : [1]
    content {
      max_throughput = var.cosmos_autoscale_max_throughput
    }
  }
}

resource "azurerm_private_endpoint" "cosmos" {
  count               = var.enable_cosmos ? 1 : 0
  name                = "${var.name_prefix}-cosmos-pe-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "cosmos-psc"
    private_connection_resource_id = azurerm_cosmosdb_account.main[0].id
    subresource_names              = ["Sql"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.documents.azure.com"]]
  }
}

resource "azurerm_monitor_diagnostic_setting" "cosmos" {
  count                          = var.enable_cosmos ? 1 : 0
  name                           = "diag-to-law"
  target_resource_id             = azurerm_cosmosdb_account.main[0].id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category_group = "allLogs"
  }
  enabled_metric {
    category = "Requests"
  }
}
