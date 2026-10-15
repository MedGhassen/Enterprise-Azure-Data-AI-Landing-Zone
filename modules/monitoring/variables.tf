variable "name_prefix" {
  description = "Prefix for resource names, e.g. `dataai-dev-weu`."
  type        = string
}

variable "name_suffix" {
  description = "Instance suffix for resource names, e.g. `001`."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "location_display_name" {
  description = "Display name of the region used by Service Health alerts, e.g. `West Europe`."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for monitoring resources."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "Log Analytics retention in days (30-730)."
  type        = number
  default     = 90
  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "log_retention_days must be between 30 and 730."
  }
}

variable "daily_quota_gb" {
  description = "Daily ingestion cap in GB (-1 = unlimited). Useful to cap dev costs."
  type        = number
  default     = -1
}

variable "action_group_emails" {
  description = "Email addresses notified by the action group."
  type        = list(string)
  default     = []
}

variable "action_group_webhook_url" {
  description = "Optional webhook (e.g. Teams/Slack) for the action group."
  type        = string
  default     = null
  sensitive   = true
}
