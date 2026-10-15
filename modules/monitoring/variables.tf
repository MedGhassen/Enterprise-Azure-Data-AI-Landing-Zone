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
  description = "Resource group for monitoring resources"
  type        = string
}

variable "log_retention_days" {
  description = "Log Analytics retention in days"
  type        = number
  default     = 90
}

variable "action_group_emails" {
  description = "Email addresses for alert notifications"
  type        = list(string)
  default     = []
}

variable "action_group_webhook_url" {
  description = "Webhook URL for alert notifications"
  type        = string
  default     = ""
}

variable "create_dashboard" {
  description = "Create Azure Portal dashboard"
  type        = bool
  default     = false
}

variable "sku" {
  description = "Log Analytics SKU (PerGB2018, Free, Standalone, etc.)"
  type        = string
  default     = "PerGB2018"
}
