output "workspace_id" {
  description = "Databricks workspace resource ID."
  value       = azurerm_databricks_workspace.main.id
}

output "workspace_url" {
  description = "Databricks workspace URL."
  value       = azurerm_databricks_workspace.main.workspace_url
}

output "access_connector_id" {
  description = "Access Connector ID for the Unity Catalog storage credential."
  value       = azurerm_databricks_access_connector.unity.id
}
