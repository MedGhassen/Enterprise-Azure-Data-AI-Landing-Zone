output "event_hubs_namespace_id" {
  description = "Event Hubs namespace ID."
  value       = azurerm_eventhub_namespace.main.id
}

output "event_hubs_namespace_name" {
  description = "Event Hubs namespace name."
  value       = azurerm_eventhub_namespace.main.name
}

output "stream_analytics_job_id" {
  description = "Stream Analytics job ID (null when disabled)."
  value       = try(azurerm_stream_analytics_job.main[0].id, null)
}
