output "sql_server_id" {
  description = "Azure SQL server ID (null when disabled)."
  value       = try(azurerm_mssql_server.main[0].id, null)
}

output "sql_server_fqdn" {
  description = "Azure SQL server FQDN (null when disabled)."
  value       = try(azurerm_mssql_server.main[0].fully_qualified_domain_name, null)
}

output "cosmos_db_id" {
  description = "Cosmos DB account ID (null when disabled)."
  value       = try(azurerm_cosmosdb_account.main[0].id, null)
}

output "cosmos_db_endpoint" {
  description = "Cosmos DB endpoint (null when disabled)."
  value       = try(azurerm_cosmosdb_account.main[0].endpoint, null)
}
