output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID."
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_guid" {
  description = "Log Analytics workspace (customer) ID."
  value       = azurerm_log_analytics_workspace.main.workspace_id
}

output "application_insights_id" {
  description = "Application Insights resource ID."
  value       = azurerm_application_insights.main.id
}

output "action_group_id" {
  description = "Action group ID for alerts."
  value       = azurerm_monitor_action_group.main.id
}
