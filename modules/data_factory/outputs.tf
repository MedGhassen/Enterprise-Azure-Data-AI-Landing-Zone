output "data_factory_id" {
  description = "Data Factory ID."
  value       = azurerm_data_factory.main.id
}

output "data_factory_name" {
  description = "Data Factory name."
  value       = azurerm_data_factory.main.name
}

output "principal_id" {
  description = "Data Factory managed identity principal ID."
  value       = azurerm_data_factory.main.identity[0].principal_id
}
