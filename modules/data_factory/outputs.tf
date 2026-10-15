output "data_factory_id" {
  description = "Data Factory resource ID"
  value       = azurerm_data_factory.main.id
}

output "data_factory_name" {
  description = "Data Factory name"
  value       = azurerm_data_factory.main.name
}

output "managed_identity_principal_id" {
  description = "Data Factory system-assigned managed identity principal ID"
  value       = azurerm_data_factory.main.identity[0].principal_id
}
