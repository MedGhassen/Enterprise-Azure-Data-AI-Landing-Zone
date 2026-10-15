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
  description = "Resource group for security resources."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "private_endpoint_subnet_id" {
  description = "Subnet for the Key Vault private endpoint."
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

variable "key_vault_sku" {
  description = "Key Vault SKU (standard or premium)."
  type        = string
  default     = "premium"
  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "key_vault_sku must be standard or premium."
  }
}

variable "soft_delete_retention_days" {
  description = "Soft-delete retention (7-90 days)."
  type        = number
  default     = 90
}

variable "purge_protection_enabled" {
  description = "Enable purge protection. Recommended for prod; once enabled it cannot be disabled."
  type        = bool
  default     = true
}

variable "enable_defender" {
  description = "Manage Defender for Cloud plans and security contact for the current subscription."
  type        = bool
  default     = false
}

variable "defender_plans" {
  description = "Defender for Cloud plans to enable (resource types)."
  type        = list(string)
  default     = ["StorageAccounts", "SqlServers", "KeyVaults", "Containers", "Arm", "CosmosDbs", "AI"]
}

variable "defender_contact_email" {
  description = "Security contact email for Defender alerts."
  type        = string
  default     = null
}

variable "defender_contact_phone" {
  description = "Optional security contact phone number."
  type        = string
  default     = null
}
