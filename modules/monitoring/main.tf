data "azurerm_client_config" "current" {}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.name_prefix}-law-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# Workspace-based Application Insights
resource "azurerm_application_insights" "main" {
  name                = "${var.name_prefix}-appi-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "other"
  tags                = var.tags
}

# Action group for alerts
resource "azurerm_monitor_action_group" "main" {
  name                = "${var.name_prefix}-ag-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  short_name          = "dataaialert"
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = var.action_group_emails
    content {
      name          = "email-${email_receiver.key}"
      email_address = email_receiver.value
    }
  }

  dynamic "webhook_receiver" {
    for_each = var.action_group_webhook_url != "" ? [1] : []
    content {
      name        = "webhook"
      service_uri = var.action_group_webhook_url
    }
  }
}

# Metric alerts - placeholder; actual resource IDs passed via variables in root
# Log alerts and metric alerts are created when target resource IDs are available
# Optional dashboard
resource "azurerm_portal_dashboard" "main" {
  count               = var.create_dashboard ? 1 : 0
  name                = "${var.name_prefix}-dashboard-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.primary_region
  tags                = var.tags
  dashboard_properties = jsonencode({
    lenses = {
      "0" = {
        order = 0
        parts = {
          "0" = {
            position = { x = 0, y = 0, colSpan = 6, rowSpan = 4 }
            metadata = {
              type     = "Extension/HubsExtension/PartType/MarkdownPart"
              settings = { content = { content = "# Data & AI Landing Zone\n\nOperational overview.", title = "" } }
            }
          }
        }
      }
    }
    metadata = { model = { timeRange = { value = "PT24H", type = "PT24H" } } }
  })
}
