variable "project_name" {
  description = "Project name for naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "primary_region" {
  description = "Azure region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "name_suffix" {
  description = "Suffix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "Resource group for streaming"
  type        = string
}

variable "event_hubs_sku" {
  description = "Event Hubs namespace SKU (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
}

variable "event_hubs" {
  description = "List of event hubs: name, partition_count, message_retention"
  type = list(object({
    name              = string
    partition_count   = number
    message_retention = number
  }))
  default = [{ name = "ingest", partition_count = 4, message_retention = 1 }]
}

variable "capture_storage_account_id" {
  description = "Storage account ID for Event Hubs capture (ADLS Gen2)"
  type        = string
  default     = ""
}

variable "capture_container_name" {
  description = "Container name for capture"
  type        = string
  default     = "eventhub-capture"
}

variable "subnet_id_private_endpoint" {
  description = "Subnet for Event Hubs private endpoint"
  type        = string
  default     = ""
}

variable "enable_private_endpoint" {
  description = "Create private endpoint for Event Hubs"
  type        = bool
  default     = true
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for Stream Analytics"
  type        = bool
  default     = true
}

variable "private_dns_zone_eventhub_name" {
  type    = string
  default = ""
}

variable "private_dns_zone_eventhub_rg" {
  type    = string
  default = ""
}

variable "stream_analytics_sku" {
  description = "Stream Analytics job SKU"
  type        = string
  default     = "Standard"
}

variable "stream_analytics_streaming_units" {
  description = "Streaming units for Stream Analytics"
  type        = number
  default     = 3
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics for Stream Analytics diagnostics"
  type        = string
  default     = ""
}
