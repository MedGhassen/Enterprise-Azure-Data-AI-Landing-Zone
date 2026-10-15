# Azure AI Search: Entra-only (no API keys), private endpoint only.
resource "azurerm_search_service" "main" {
  count                         = var.enable_search ? 1 : 0
  name                          = "${var.name_prefix}-srch-${var.unique_suffix}-${var.name_suffix}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.search_sku
  replica_count                 = var.search_replica_count
  partition_count               = var.search_partition_count
  semantic_search_sku           = var.search_semantic_sku
  local_authentication_enabled  = false
  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_private_endpoint" "search" {
  count               = var.enable_search ? 1 : 0
  name                = "${var.name_prefix}-srch-pe-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "srch-psc"
    private_connection_resource_id = azurerm_search_service.main[0].id
    subresource_names              = ["searchService"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.search.windows.net"]]
  }
}

resource "azurerm_monitor_diagnostic_setting" "search" {
  count                      = var.enable_search ? 1 : 0
  name                       = "diag-to-law"
  target_resource_id         = azurerm_search_service.main[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}
