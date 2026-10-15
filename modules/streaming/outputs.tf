output "event_hubs_namespace" {
  description = "Event Hubs namespace name"
  value       = azurerm_eventhub_namespace.main.name
}

output "event_hubs_namespace_id" {
  description = "Event Hubs namespace resource ID"
  value       = azurerm_eventhub_namespace.main.id
}

output "stream_analytics_job_id" {
  description = "Stream Analytics job resource ID"
  value       = azurerm_stream_analytics_job.main.id
}

output "stream_analytics_job_name" {
  description = "Stream Analytics job name"
  value       = azurerm_stream_analytics_job.main.name
}
