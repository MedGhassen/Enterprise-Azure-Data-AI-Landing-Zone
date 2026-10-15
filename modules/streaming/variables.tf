variable "name_prefix" {
  description = "Prefix for resource names, e.g. `dataai-dev-weu`."
  type        = string
}

variable "name_suffix" {
  description = "Instance suffix for resource names, e.g. `001`."
  type        = string
}

variable "unique_suffix" {
  description = "Short random suffix used for globally unique names."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for streaming resources."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "private_endpoint_subnet_id" {
  description = "Subnet for the Event Hubs private endpoint."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs keyed by zone name (from the networking module)."
  type        = map(string)
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics."
  type        = string
}

variable "event_hubs_sku" {
  description = "Event Hubs namespace SKU. Standard or Premium (private endpoints are not available on Basic)."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.event_hubs_sku)
    error_message = "event_hubs_sku must be Standard or Premium."
  }
}

variable "event_hubs_capacity" {
  description = "Throughput units (Standard) or processing units (Premium)."
  type        = number
  default     = 1
}

variable "event_hubs_max_throughput_units" {
  description = "Auto-inflate maximum throughput units (Standard only, 0 disables auto-inflate)."
  type        = number
  default     = 0
}

variable "event_hubs" {
  description = "Event hubs to create."
  type = list(object({
    name              = string
    partition_count   = optional(number, 4)
    message_retention = optional(number, 7)
  }))
  default = [{ name = "ingest" }]
}

variable "enable_stream_analytics" {
  description = "Create a Stream Analytics job."
  type        = bool
  default     = false
}

variable "stream_analytics_streaming_units" {
  description = "Streaming units for the Stream Analytics job."
  type        = number
  default     = 3
}

variable "stream_analytics_query" {
  description = "Stream Analytics transformation query. Inputs/outputs must be defined separately."
  type        = string
  default     = "SELECT * INTO [output] FROM [input]"
}
