variable "project_name" {
  description = "Project name for naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "management_group_parent_id" {
  description = "Parent management group ID (e.g. tenant root)"
  type        = string
  default     = ""
}

variable "create_management_group_hierarchy" {
  description = "Create Platform -> Landing Zones -> Sandbox hierarchy"
  type        = bool
  default     = true
}

variable "subscription_id" {
  description = "Subscription ID to associate with Landing Zones (legacy single-sub; use subscription_id_dataai_* when using multi-sub)"
  type        = string
  default     = ""
}

variable "create_identity_management_group" {
  description = "Create Identity child management group under Platform (for hybrid AD)"
  type        = bool
  default     = false
}

# Optional subscription IDs for multi-subscription layout; empty = skip association
variable "subscription_id_connectivity" {
  description = "Subscription ID for Connectivity (Hub, Firewall, DNS); associate with Platform/Connectivity MG"
  type        = string
  default     = ""
}

variable "subscription_id_management" {
  description = "Subscription ID for Management (Log Analytics, Defender, Sentinel); associate with Platform/Management MG"
  type        = string
  default     = ""
}

variable "subscription_id_identity" {
  description = "Subscription ID for Identity (hybrid AD); associate with Platform/Identity MG"
  type        = string
  default     = ""
}

variable "subscription_id_dataai_dev" {
  description = "Subscription ID for Data & AI Dev; associate with Landing Zones/Data & AI Dev MG"
  type        = string
  default     = ""
}

variable "subscription_id_dataai_staging" {
  description = "Subscription ID for Data & AI Staging; associate with Landing Zones/Data & AI Staging MG"
  type        = string
  default     = ""
}

variable "subscription_id_dataai_prod" {
  description = "Subscription ID for Data & AI Prod; associate with Landing Zones/Data & AI Prod MG"
  type        = string
  default     = ""
}

variable "subscription_id_sandbox" {
  description = "Subscription ID for Sandbox; associate with Sandbox child MG"
  type        = string
  default     = ""
}

variable "policy_assignments" {
  description = "List of policy assignments: policy_definition_id (or display_name for built-in), management_group_id, parameters (optional)"
  type = list(object({
    policy_definition_id = optional(string)
    builtin_policy_name  = optional(string) # e.g. allowed-locations
    management_group_id  = string
    display_name         = optional(string)
    parameters           = optional(string) # JSON
    enforcement_mode     = optional(bool, true)
  }))
  default = []
}

variable "custom_roles" {
  description = "Custom RBAC role definitions: name, scope (subscription or management group ID), actions, assignable_scopes"
  type = list(object({
    name              = string
    scope             = string
    description       = string
    actions           = list(string)
    assignable_scopes = list(string)
  }))
  default = []
}

variable "role_assignments" {
  description = "Role assignments: principal_id, role_definition_id or role_definition_name, scope (resource group ID or scope)"
  type = list(object({
    principal_id         = string
    role_definition_id   = optional(string)
    role_definition_name = optional(string) # built-in: Reader, Contributor, Storage Blob Data Contributor
    scope                = string
  }))
  default = []
}

variable "allowed_locations" {
  description = "Allowed Azure regions for policy"
  type        = list(string)
  default     = ["westeurope", "northeurope"]
}

variable "allowed_vm_skus" {
  description = "Allowed VM SKUs for policy (empty = use default set)"
  type        = list(string)
  default     = []
}

# Compliance policy assignments (optional; only assign when enable_* is true)
variable "enable_iso27001" {
  description = "Assign ISO 27001:2013 Regulatory Compliance initiative at compliance_policy_scope_mg"
  type        = bool
  default     = false
}

variable "enable_nis2" {
  description = "Assign NIS2 initiative when nis2_initiative_id is set"
  type        = bool
  default     = false
}

variable "nis2_initiative_id" {
  description = "Policy set definition (initiative) ID for NIS2; required when enable_nis2 is true (custom/partner initiative)"
  type        = string
  default     = ""
}

variable "compliance_policy_scope_mg" {
  description = "Management group key for compliance policy assignment: landing_zones, platform, or sandbox"
  type        = string
  default     = "landing_zones"
}

variable "compliance_policy_parameters_iso27001" {
  description = "Optional parameters for ISO 27001 initiative assignment (JSON string)"
  type        = string
  default     = "{}"
}

variable "compliance_policy_parameters_nis2" {
  description = "Optional parameters for NIS2 initiative assignment (JSON string)"
  type        = string
  default     = "{}"
}

# Optional: extensible list for additional compliance initiatives
variable "compliance_policy_assignments" {
  description = "Additional compliance assignments: enable, initiative_display_name or policy_set_definition_id, assignment_scope (landing_zones|platform|sandbox), parameters (JSON string)"
  type = list(object({
    enable                   = bool
    initiative_display_name  = optional(string)
    policy_set_definition_id = optional(string)
    assignment_scope         = optional(string, "landing_zones")
    parameters               = optional(string, "{}")
    assignment_name          = optional(string) # unique name for the assignment
  }))
  default = []
}
