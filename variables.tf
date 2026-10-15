variable "project_name" {
  description = "Project name used in naming and tags"
  type        = string
  default     = "dataai"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "primary_region" {
  description = "Primary Azure region for deployment"
  type        = string
  default     = "westeurope"
  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2", "westeurope", "northeurope",
      "uksouth", "ukwest", "southeastasia", "eastasia", "australiaeast",
      "canadacentral", "centralus", "northcentralus", "southcentralus",
      "francecentral", "germanywestcentral", "swedencentral", "norwayeast"
    ], lower(var.primary_region))
    error_message = "primary_region must be an allowed Azure region."
  }
}

variable "cost_center" {
  description = "Cost center for billing and tags"
  type        = string
  default     = "CC001"
}

variable "owner_email" {
  description = "Owner email for tags and alerts"
  type        = string
}

variable "resource_prefix" {
  description = "Short prefix for resource names (e.g. dataai)"
  type        = string
  default     = "dataai"
  validation {
    condition     = length(var.resource_prefix) >= 2 && length(var.resource_prefix) <= 10
    error_message = "resource_prefix must be 2-10 characters."
  }
}

variable "instance_suffix" {
  description = "Instance number suffix (e.g. 001). Empty to use default 001."
  type        = string
  default     = ""
}

# Feature flags
variable "enable_bastion" {
  description = "Enable Azure Bastion in hub VNet"
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  description = "Enable P2S VPN Gateway with Entra ID auth and DNS Private Resolver in hub"
  type        = bool
  default     = false
}

variable "vpn_client_address_pool" {
  description = "Address pool for P2S VPN clients (must not overlap with hub/spoke CIDRs)"
  type        = string
  default     = "172.16.0.0/24"
}

variable "enable_purview" {
  description = "Enable Microsoft Purview (typically prod only)"
  type        = bool
  default     = false
}

# Governance
variable "subscription_id" {
  description = "Azure subscription ID for management group association (legacy single-sub)"
  type        = string
  default     = ""
}

variable "management_group_id_landing_zones" {
  description = "Management group ID for Landing Zones (for policy assignment)"
  type        = string
  default     = ""
}

# Multi-subscription: optional subscription IDs per scope (empty = skip association)
variable "subscription_id_connectivity" {
  description = "Subscription ID for Platform/Connectivity (Hub, Firewall, DNS)"
  type        = string
  default     = ""
}

variable "subscription_id_management" {
  description = "Subscription ID for Platform/Management (Log Analytics, Defender, Sentinel)"
  type        = string
  default     = ""
}

variable "subscription_id_identity" {
  description = "Subscription ID for Platform/Identity (hybrid Identity)"
  type        = string
  default     = ""
}

variable "subscription_id_dataai_dev" {
  description = "Subscription ID for Data & AI Dev"
  type        = string
  default     = ""
}

variable "subscription_id_dataai_staging" {
  description = "Subscription ID for Data & AI Staging"
  type        = string
  default     = ""
}

variable "subscription_id_dataai_prod" {
  description = "Subscription ID for Data & AI Prod"
  type        = string
  default     = ""
}

variable "subscription_id_sandbox" {
  description = "Subscription ID for Sandbox"
  type        = string
  default     = ""
}

variable "create_identity_management_group" {
  description = "Create Identity child management group under Platform"
  type        = bool
  default     = false
}

# Compliance policies (assign at management group when enable_* is true)
variable "enable_iso27001" {
  description = "Assign ISO 27001:2013 Regulatory Compliance initiative"
  type        = bool
  default     = false
}

variable "enable_nis2" {
  description = "Assign NIS2 initiative (requires nis2_initiative_id when true)"
  type        = bool
  default     = false
}

variable "nis2_initiative_id" {
  description = "Policy set definition ID for NIS2 (custom/partner initiative)"
  type        = string
  default     = ""
}

variable "compliance_policy_scope_mg" {
  description = "Management group for compliance assignments: landing_zones, platform, or sandbox"
  type        = string
  default     = "landing_zones"
}

variable "compliance_policy_parameters_iso27001" {
  description = "Optional parameters for ISO 27001 assignment (JSON string)"
  type        = string
  default     = "{}"
}

variable "compliance_policy_parameters_nis2" {
  description = "Optional parameters for NIS2 assignment (JSON string)"
  type        = string
  default     = "{}"
}

variable "compliance_policy_assignments" {
  description = "Additional compliance initiatives: enable, initiative_display_name or policy_set_definition_id, assignment_scope, parameters, assignment_name"
  type = list(object({
    enable                   = bool
    initiative_display_name  = optional(string)
    policy_set_definition_id = optional(string)
    assignment_scope         = optional(string, "landing_zones")
    parameters               = optional(string, "{}")
    assignment_name          = optional(string)
  }))
  default = []
}

# Git for Data Factory
variable "adf_repo_config" {
  description = "Data Factory Git repo: type (AzureDevOpsGit or GitHub), repo_url, branch, root_folder"
  type = object({
    type        = string
    repo_url    = string
    branch      = string
    root_folder = string
  })
  default = {
    type        = "GitHub"
    repo_url    = ""
    branch      = "main"
    root_folder = "/"
  }
}

# Backend (for partial override in pipelines)
variable "backend_resource_group_name" {
  description = "Resource group for Terraform state storage (override in pipeline)"
  type        = string
  default     = "rg-terraform-state"
}

variable "backend_storage_account_name" {
  description = "Storage account for Terraform state (override in pipeline)"
  type        = string
  default     = "sttfstate8df72ee1"
}

variable "backend_container_name" {
  description = "Container name for Terraform state"
  type        = string
  default     = "tfstate"
}
