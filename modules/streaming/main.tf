# Event Hubs namespace: Entra-only (no SAS keys), private endpoint only.
resource "azurerm_eventhub_namespace" "main" {
  name                          = "${var.name_prefix}-evhns-${var.unique_suffix}-${var.name_suffix}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.event_hubs_sku
  capacity                      = var.event_hubs_capacity
  auto_inflate_enabled          = var.event_hubs_sku == "Standard" && var.event_hubs_max_throughput_units > 0
  maximum_throughput_units      = var.event_hubs_sku == "Standard" && var.event_hubs_max_throughput_units > 0 ? var.event_hubs_max_throughput_units : null
  public_network_access_enabled = false
  local_authentication_enabled  = false
  minimum_tls_version           = "1.2"
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_eventhub" "hubs" {
  for_each          = { for h in var.event_hubs : h.name => h }
  name              = each.value.name
  namespace_id      = azurerm_eventhub_namespace.main.id
  partition_count   = each.value.partition_count
  message_retention = each.value.message_retention
}

resource "azurerm_private_endpoint" "eventhubs" {
  name                = "${var.name_prefix}-evh-pe-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "evh-psc"
    private_connection_resource_id = azurerm_eventhub_namespace.main.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.servicebus.windows.net"]]
  }
}

resource "azurerm_monitor_diagnostic_setting" "eventhubs" {
  name                           = "diag-to-law"
  target_resource_id             = azurerm_eventhub_namespace.main.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category_group = "allLogs"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}

# ---------------------------------------------------------------------------
# Stream Analytics (optional). Provide your own query, inputs and outputs.
# ---------------------------------------------------------------------------
resource "azurerm_stream_analytics_job" "main" {
  count                = var.enable_stream_analytics ? 1 : 0
  name                 = "${var.name_prefix}-asa-${var.name_suffix}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  streaming_units      = var.stream_analytics_streaming_units
  transformation_query = var.stream_analytics_query
  tags                 = var.tags

  identity {
    type = "SystemAssigned"
  }
}

# Stream Analytics identity can read from Event Hubs.
resource "azurerm_role_assignment" "asa_eventhubs" {
  count                = var.enable_stream_analytics ? 1 : 0
  scope                = azurerm_eventhub_namespace.main.id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azurerm_stream_analytics_job.main[0].identity[0].principal_id
}

resource "azurerm_monitor_diagnostic_setting" "asa" {
  count                      = var.enable_stream_analytics ? 1 : 0
  name                       = "diag-to-law"
  target_resource_id         = azurerm_stream_analytics_job.main[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}
