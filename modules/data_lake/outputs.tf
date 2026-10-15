output "storage_account_id" {
  description = "Storage account resource ID"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.main.name
}

output "storage_primary_blob_endpoint" {
  description = "Primary blob endpoint"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "storage_dfs_endpoint" {
  description = "Primary DFS endpoint (ADLS Gen2)"
  value       = azurerm_storage_account.main.primary_dfs_endpoint
}

output "storage_primary_blob_host" {
  description = "Primary blob host (for DNS A record name)"
  value       = azurerm_storage_account.main.primary_blob_host
}

output "storage_primary_dfs_host" {
  description = "Primary DFS host"
  value       = azurerm_storage_account.main.primary_dfs_host
}

output "filesystem_names" {
  description = "Medallion filesystem names"
  value       = ["raw", "curated", "enriched"]
}

output "resource_group_name" {
  description = "Resource group name"
  value       = var.resource_group_name
}
