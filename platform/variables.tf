variable "subscription_id" {
  description = "Subscription used for API calls. null uses ARM_SUBSCRIPTION_ID / the Azure CLI context."
  type        = string
  default     = null
}

variable "management_group_prefix" {
  description = "Prefix for management group IDs, e.g. `contoso` -> `contoso-platform`."
  type        = string
}

variable "management_group_parent_id" {
  description = "Parent management group ID. null = tenant root group."
  type        = string
  default     = null
}

variable "create_identity_management_group" {
  description = "Create the Platform/Identity management group."
  type        = bool
  default     = false
}

variable "subscription_placement" {
  description = "Subscriptions to place under management groups. Keys: platform, landing_zones, sandbox, management, connectivity, identity, dataai_dev, dataai_staging, dataai_prod."
  type        = map(string)
  default     = {}
  validation {
    condition = alltrue([for k in keys(var.subscription_placement) : contains(
      ["platform", "landing_zones", "sandbox", "management", "connectivity", "identity", "dataai_dev", "dataai_staging", "dataai_prod"], k
    )])
    error_message = "Unknown key in subscription_placement."
  }
}

variable "allowed_locations" {
  description = "Regions allowed under Landing Zones."
  type        = list(string)
  default     = ["westeurope", "northeurope"]
}

variable "required_tags" {
  description = "Tags required on resource groups and inherited by resources."
  type        = list(string)
  default     = ["environment", "cost_center", "owner"]
}

variable "policy_identity_location" {
  description = "Region for policy assignment managed identities."
  type        = string
  default     = "westeurope"
}

variable "enable_iso27001" {
  description = "Assign the ISO 27001:2013 regulatory compliance initiative."
  type        = bool
  default     = false
}

variable "enable_nis2" {
  description = "Assign a NIS2 initiative (requires nis2_initiative_id)."
  type        = bool
  default     = false
}

variable "nis2_initiative_id" {
  description = "Policy set definition ID of a custom/partner NIS2 initiative."
  type        = string
  default     = null
}

variable "compliance_policy_scope" {
  description = "Management group key for compliance assignments."
  type        = string
  default     = "landing_zones"
}

variable "compliance_policy_assignments" {
  description = "Additional initiatives to assign (see modules/governance)."
  type = list(object({
    enable                   = bool
    assignment_name          = string
    policy_set_definition_id = string
    display_name             = optional(string)
    assignment_scope         = optional(string, "landing_zones")
    parameters               = optional(string)
  }))
  default = []
}

variable "create_default_custom_roles" {
  description = "Create Data Engineer, Data Scientist and ML Engineer custom roles."
  type        = bool
  default     = true
}

variable "role_assignments" {
  description = "Role assignments (role name or custom role name; scope = management group key or resource ID)."
  type = list(object({
    principal_id = string
    role         = string
    scope        = string
  }))
  default = []
}
