output "workspace_id" {
  description = "Synapse workspace resource ID"
  value       = azurerm_synapse_workspace.main.id
}

output "workspace_name" {
  description = "Synapse workspace name"
  value       = azurerm_synapse_workspace.main.name
}

output "sql_endpoint" {
  description = "Synapse SQL connectivity endpoint host"
  value       = try(azurerm_synapse_workspace.main.connectivity_endpoints["sql"], null)
}

output "spark_endpoint" {
  description = "Synapse Spark connectivity endpoint"
  value       = try(azurerm_synapse_workspace.main.connectivity_endpoints["dev"], null)
}

output "dev_endpoint" {
  description = "Synapse dev endpoint (Spark)"
  value       = try(azurerm_synapse_workspace.main.connectivity_endpoints["dev"], null)
}

output "connectivity_endpoints" {
  description = "All connectivity endpoints (map)"
  value       = azurerm_synapse_workspace.main.connectivity_endpoints
}

output "identity_principal_id" {
  description = "Synapse workspace managed identity principal ID"
  value       = azurerm_synapse_workspace.main.identity[0].principal_id
}

output "sql_pool_id" {
  description = "Dedicated SQL pool resource ID"
  value       = azurerm_synapse_sql_pool.main.id
}
