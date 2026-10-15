output "sql_server_id" {
  description = "SQL server resource ID"
  value       = azurerm_mssql_server.main.id
}

output "sql_server_fqdn" {
  description = "SQL server FQDN"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "sql_database_id" {
  description = "SQL database resource ID"
  value       = azurerm_mssql_database.main.id
}

output "cosmos_db_id" {
  description = "Cosmos DB account ID (if created)"
  value       = try(azurerm_cosmosdb_account.main[0].id, null)
}

output "cosmos_db_endpoint" {
  description = "Cosmos DB endpoint (if created)"
  value       = try(azurerm_cosmosdb_account.main[0].endpoint, null)
}
