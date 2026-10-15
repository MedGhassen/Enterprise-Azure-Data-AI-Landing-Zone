output "workspace_id" {
  description = "Databricks workspace resource ID"
  value       = azurerm_databricks_workspace.main.id
}

output "workspace_url" {
  description = "Databricks workspace URL"
  value       = azurerm_databricks_workspace.main.workspace_url
}

output "workspace_host" {
  description = "Databricks workspace host (without https)"
  value       = replace(replace(azurerm_databricks_workspace.main.workspace_url, "https://", ""), "/", "")
}

output "metastore_id" {
  description = "Unity Catalog metastore ID (create via databricks provider separately)"
  value       = null
}
