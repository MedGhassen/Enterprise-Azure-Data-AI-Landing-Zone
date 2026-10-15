output "workspace_id" {
  description = "Synapse workspace ID."
  value       = azurerm_synapse_workspace.main.id
}

output "workspace_name" {
  description = "Synapse workspace name."
  value       = azurerm_synapse_workspace.main.name
}

output "connectivity_endpoints" {
  description = "Synapse endpoints (dev, sql, sqlOnDemand, web)."
  value       = azurerm_synapse_workspace.main.connectivity_endpoints
}

output "principal_id" {
  description = "Synapse workspace managed identity principal ID."
  value       = azurerm_synapse_workspace.main.identity[0].principal_id
}
