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
  description = "Resource group for security resources"
  type        = string
}

variable "key_vault_sku" {
  description = "Key Vault SKU (standard or premium)"
  type        = string
  default     = "premium"
  validation {
    condition     = contains(["standard", "premium"], lower(var.key_vault_sku))
    error_message = "key_vault_sku must be standard or premium."
  }
}

variable "subnet_id_private_endpoint" {
  description = "Subnet ID for Key Vault private endpoint (snet-security)"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for Key Vault diagnostic settings"
  type        = string
  default     = ""
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for Key Vault"
  type        = bool
  default     = true
}

variable "defender_plans" {
  description = "List of Defender resource types (StorageAccounts, SqlServers, KeyVaults, AppServices, Containers, Arm)"
  type        = list(string)
  default     = ["StorageAccounts", "SqlServers", "KeyVaults", "AppServices", "Containers", "Arm"]
}

variable "defender_contact_email" {
  description = "Security contact email for Microsoft Defender for Cloud"
  type        = string
}

variable "private_dns_zone_vault_name" {
  description = "Private DNS zone name for vault (privatelink.vaultcore.azure.net)"
  type        = string
  default     = ""
}

variable "private_dns_zone_vault_rg" {
  description = "Resource group where the vault private DNS zone is"
  type        = string
  default     = ""
}
