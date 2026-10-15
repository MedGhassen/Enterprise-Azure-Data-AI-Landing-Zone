resource "azurerm_eventhub_namespace" "main" {
  name                = "${var.name_prefix}-evhns-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  sku                 = var.event_hubs_sku
  capacity            = var.event_hubs_sku == "Basic" ? 1 : (var.event_hubs_sku == "Standard" ? 1 : 1)
  tags                = var.tags
}

resource "azurerm_eventhub" "hubs" {
  for_each            = { for h in var.event_hubs : h.name => h }
  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.main.name
  resource_group_name = var.resource_group_name
  partition_count     = each.value.partition_count
  message_retention   = each.value.message_retention
}

# Event Hubs capture: configure via Azure portal or separate automation (azurerm_eventhub_capture deprecated/removed in newer provider)

# Private endpoint for Event Hubs
resource "azurerm_private_endpoint" "eventhubs" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.name_prefix}-evh-pe-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_private_endpoint
  tags                = var.tags

  private_service_connection {
    name                           = "evh-psc"
    private_connection_resource_id = azurerm_eventhub_namespace.main.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_a_record" "eventhubs" {
  count               = var.enable_private_endpoint && var.private_dns_zone_eventhub_name != "" && var.private_dns_zone_eventhub_rg != "" ? 1 : 0
  name                = azurerm_eventhub_namespace.main.name
  zone_name           = var.private_dns_zone_eventhub_name
  resource_group_name = var.private_dns_zone_eventhub_rg
  ttl                 = 300
  records             = [azurerm_private_endpoint.eventhubs[0].private_service_connection[0].private_ip_address]
}

# Stream Analytics job (transformation_query required; customize with real inputs/outputs)
resource "azurerm_stream_analytics_job" "main" {
  name                = "${var.name_prefix}-asa-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.primary_region
  streaming_units     = var.stream_analytics_streaming_units
  tags                = var.tags

  transformation_query = "SELECT * INTO [YourOutput] FROM [YourInput]"
}

resource "azurerm_monitor_diagnostic_setting" "asa" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "asa-diag"
  target_resource_id         = azurerm_stream_analytics_job.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
