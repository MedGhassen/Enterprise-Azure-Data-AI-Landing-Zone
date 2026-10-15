resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.name_prefix}-law-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  daily_quota_gb      = var.daily_quota_gb
  tags                = var.tags
}

# Workspace-based Application Insights (used by Azure ML and workloads)
resource "azurerm_application_insights" "main" {
  name                = "${var.name_prefix}-appi-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "other"
  tags                = var.tags
}

resource "azurerm_monitor_action_group" "main" {
  name                = "${var.name_prefix}-ag-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  short_name          = substr(replace(var.name_prefix, "-", ""), 0, 12)
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = var.action_group_emails
    content {
      name                    = "email-${email_receiver.key}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }

  dynamic "webhook_receiver" {
    for_each = nonsensitive(var.action_group_webhook_url != null) ? [1] : []
    content {
      name                    = "webhook"
      service_uri             = var.action_group_webhook_url
      use_common_alert_schema = true
    }
  }
}

# Service Health alerts for the subscription, routed to the action group.
data "azurerm_subscription" "current" {}

resource "azurerm_monitor_activity_log_alert" "service_health" {
  name                = "${var.name_prefix}-alert-servicehealth-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [data.azurerm_subscription.current.id]
  description         = "Azure Service Health incidents affecting the landing zone regions."
  tags                = var.tags

  criteria {
    category = "ServiceHealth"
    service_health {
      locations = [var.location_display_name, "Global"]
      events    = ["Incident", "Security"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
