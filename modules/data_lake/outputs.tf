output "storage_account_id" {
  description = "ADLS Gen2 storage account ID."
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "ADLS Gen2 storage account name."
  value       = azurerm_storage_account.main.name
}

output "dfs_endpoint" {
  description = "ADLS Gen2 DFS endpoint."
  value       = azurerm_storage_account.main.primary_dfs_endpoint
}

output "filesystems" {
  description = "Created filesystems keyed by name (value: container ID)."
  value       = { for k, c in azurerm_storage_container.filesystems : k => c.id }
}
