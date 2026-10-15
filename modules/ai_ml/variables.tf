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
  description = "Resource group for AI/ML"
  type        = string
}

variable "subnet_id_ai" {
  description = "Subnet for ML/OpenAI/Cognitive/Search private endpoints (snet-ai)"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault ID for ML workspace and AI Foundry"
  type        = string
}

variable "storage_account_id" {
  description = "Storage account ID for ML workspace and AI Foundry"
  type        = string
}

variable "application_insights_id" {
  description = "Application Insights ID for ML workspace and AI Foundry"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = ""
}

# ML workspace
variable "ml_compute_vm_size" {
  description = "Default compute instance/cluster VM size"
  type        = string
  default     = "Standard_DS3_v2"
}

# AI Foundry
variable "ai_foundry_projects" {
  description = "List of AI Foundry project configs: name, display_name"
  type = list(object({
    name         = string
    display_name = string
  }))
  default = []
}

# OpenAI
variable "openai_deployments" {
  description = "List of OpenAI deployments: name, model, version, capacity"
  type = list(object({
    name     = string
    model    = string
    version  = string
    capacity = number
  }))
  default = []
}

# AI Search
variable "ai_search_replica_count" {
  type    = number
  default = 1
}

variable "ai_search_partition_count" {
  type    = number
  default = 1
}

variable "ai_search_semantic_search" {
  type    = bool
  default = true
}

# Private DNS (name + rg for each service)
variable "dns_zone_aml_name" {
  type    = string
  default = ""
}

variable "dns_zone_aml_rg" {
  type    = string
  default = ""
}

variable "dns_zone_openai_name" {
  type    = string
  default = ""
}

variable "dns_zone_openai_rg" {
  type    = string
  default = ""
}

variable "dns_zone_cognitive_name" {
  type    = string
  default = ""
}

variable "dns_zone_cognitive_rg" {
  type    = string
  default = ""
}

variable "dns_zone_search_name" {
  type    = string
  default = ""
}

variable "dns_zone_search_rg" {
  type    = string
  default = ""
}

variable "vnet_subnet_id_openai" {
  description = "VNet subnet ID for OpenAI network rule (snet-ai)"
  type        = string
  default     = ""
}
