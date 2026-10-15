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
  description = "Resource group for AI resources."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "private_endpoint_subnet_id" {
  description = "Subnet for AI private endpoints (snet-ai)."
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

# Foundry
variable "enable_foundry" {
  description = "Deploy a Microsoft Foundry (AI Services) account with projects and model deployments."
  type        = bool
  default     = true
}

variable "foundry_projects" {
  description = "Foundry projects to create."
  type = list(object({
    name         = string
    display_name = optional(string)
    description  = optional(string)
  }))
  default = [{ name = "main", display_name = "Main project" }]
}

variable "model_deployments" {
  description = "Model deployments on the Foundry account. Check regional availability and retirement dates before changing: https://learn.microsoft.com/azure/ai-foundry/openai/concepts/models"
  type = list(object({
    name     = string
    model    = string
    version  = string
    format   = optional(string, "OpenAI")
    sku_name = optional(string, "GlobalStandard")
    capacity = optional(number, 10)
  }))
  default = [
    { name = "gpt-4.1-mini", model = "gpt-4.1-mini", version = "2025-04-14", capacity = 10 },
    { name = "text-embedding-3-large", model = "text-embedding-3-large", version = "1", sku_name = "Standard", capacity = 10 },
  ]
}

# AI Search
variable "enable_search" {
  description = "Deploy Azure AI Search."
  type        = bool
  default     = true
}

variable "search_sku" {
  description = "AI Search SKU (basic, standard, standard2, standard3, storage_optimized_l1/l2). Private endpoints need basic or higher."
  type        = string
  default     = "standard"
  validation {
    condition     = var.search_sku != "free"
    error_message = "The free tier does not support private endpoints."
  }
}

variable "search_replica_count" {
  description = "AI Search replicas (2+ for read SLA, 3+ for read/write SLA)."
  type        = number
  default     = 1
}

variable "search_partition_count" {
  description = "AI Search partitions."
  type        = number
  default     = 1
}

variable "search_semantic_sku" {
  description = "Semantic ranker plan (free or standard), null to disable."
  type        = string
  default     = "free"
}

# Azure ML
variable "enable_ml_workspace" {
  description = "Deploy an Azure Machine Learning workspace."
  type        = bool
  default     = true
}

variable "key_vault_id" {
  description = "Key Vault ID used by the ML workspace."
  type        = string
}

variable "application_insights_id" {
  description = "Application Insights ID used by the ML workspace."
  type        = string
}

variable "container_registry_id" {
  description = "Private Premium ACR for ML images (recommended for private workspaces). null lets Azure ML create one on demand."
  type        = string
  default     = null
}

variable "ml_isolation_mode" {
  description = "Managed network isolation: AllowInternetOutbound or AllowOnlyApprovedOutbound."
  type        = string
  default     = "AllowInternetOutbound"
  validation {
    condition     = contains(["AllowInternetOutbound", "AllowOnlyApprovedOutbound"], var.ml_isolation_mode)
    error_message = "ml_isolation_mode must be AllowInternetOutbound or AllowOnlyApprovedOutbound."
  }
}
