output "ml_workspace_id" {
  description = "Azure ML workspace resource ID"
  value       = azurerm_machine_learning_workspace.main.id
}

output "ai_foundry_hub_id" {
  description = "Azure AI Foundry Hub resource ID"
  value       = azapi_resource.ai_foundry_hub.id
}

output "ai_foundry_project_ids" {
  description = "Azure AI Foundry project resource IDs"
  value       = { for k, r in azapi_resource.ai_foundry_project : k => r.id }
}

output "openai_endpoint" {
  description = "Azure OpenAI endpoint (use with custom subdomain in private DNS)"
  value       = azurerm_cognitive_account.openai.endpoint
}

output "openai_primary_key" {
  description = "OpenAI primary key (prefer managed identity in production)"
  value       = azurerm_cognitive_account.openai.primary_access_key
  sensitive   = true
}

output "cognitive_services_endpoint" {
  description = "Cognitive Services endpoint"
  value       = azurerm_cognitive_account.multi.endpoint
}

output "ai_search_endpoint" {
  description = "AI Search endpoint URL"
  value       = "https://${azurerm_search_service.main.name}.search.windows.net"
}
