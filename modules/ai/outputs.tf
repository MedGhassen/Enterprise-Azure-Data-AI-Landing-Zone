output "foundry_account_id" {
  description = "Foundry (AI Services) account ID (null when disabled)."
  value       = try(azurerm_cognitive_account.foundry[0].id, null)
}

output "foundry_endpoint" {
  description = "Foundry (AI Services) endpoint (null when disabled)."
  value       = try(azurerm_cognitive_account.foundry[0].endpoint, null)
}

output "foundry_project_ids" {
  description = "Foundry project IDs keyed by name."
  value       = { for k, p in azurerm_cognitive_account_project.projects : k => p.id }
}

output "model_deployment_names" {
  description = "Model deployment names."
  value       = keys(azurerm_cognitive_deployment.models)
}

output "search_service_id" {
  description = "AI Search service ID (null when disabled)."
  value       = try(azurerm_search_service.main[0].id, null)
}

output "search_endpoint" {
  description = "AI Search endpoint (null when disabled)."
  value       = try("https://${azurerm_search_service.main[0].name}.search.windows.net", null)
}

output "ml_workspace_id" {
  description = "Azure ML workspace ID (null when disabled)."
  value       = try(azurerm_machine_learning_workspace.main[0].id, null)
}
