variable "management_group_prefix" {
  description = "Prefix for management group IDs (names), e.g. `contoso` -> `contoso-platform`."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{2,30}$", var.management_group_prefix))
    error_message = "management_group_prefix must be 2-30 lowercase letters, digits or hyphens."
  }
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
  description = "Subscriptions to move under management groups. Keys: platform, landing_zones, sandbox, management, connectivity, identity, dataai_dev, dataai_staging, dataai_prod."
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
}

variable "required_tags" {
  description = "Tags required on resource groups and inherited by resources."
  type        = list(string)
  default     = ["environment", "cost_center", "owner"]
}

variable "policy_identity_location" {
  description = "Region for the managed identities of policy assignments."
  type        = string
}

# Compliance
variable "enable_iso27001" {
  description = "Assign the built-in ISO 27001:2013 regulatory compliance initiative."
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
  validation {
    condition     = var.nis2_initiative_id == null || can(regex("/providers/Microsoft.Authorization/policySetDefinitions/", var.nis2_initiative_id))
    error_message = "nis2_initiative_id must be a policy set definition resource ID."
  }
}

variable "compliance_policy_scope" {
  description = "Management group key for compliance assignments (landing_zones, platform, sandbox, ...)."
  type        = string
  default     = "landing_zones"
}

variable "compliance_policy_parameters_iso27001" {
  description = "Parameters (JSON) for the ISO 27001 assignment."
  type        = string
  default     = null
}

variable "compliance_policy_parameters_nis2" {
  description = "Parameters (JSON) for the NIS2 assignment."
  type        = string
  default     = null
}

variable "compliance_policy_assignments" {
  description = "Additional initiatives to assign."
  type = list(object({
    enable                   = bool
    assignment_name          = string
    policy_set_definition_id = string
    display_name             = optional(string)
    assignment_scope         = optional(string, "landing_zones")
    parameters               = optional(string)
  }))
  default = []
  validation {
    condition     = alltrue([for a in var.compliance_policy_assignments : length(a.assignment_name) <= 24])
    error_message = "assignment_name must be at most 24 characters (management group scope limit)."
  }
}

# RBAC
variable "create_default_custom_roles" {
  description = "Create Data Engineer, Data Scientist and ML Engineer custom roles at the Landing Zones scope."
  type        = bool
  default     = true
}

variable "custom_role_name_prefix" {
  description = "Prefix for default custom role names."
  type        = string
  default     = "Data & AI"
}

variable "custom_roles" {
  description = "Additional custom roles (defined and assignable at the Landing Zones scope)."
  type = list(object({
    name         = string
    description  = string
    actions      = list(string)
    not_actions  = optional(list(string), [])
    data_actions = optional(list(string), [])
  }))
  default = []
}

variable "role_assignments" {
  description = "Role assignments. role: built-in role name or custom role name; scope: management group key (e.g. dataai_prod) or a full resource ID."
  type = list(object({
    principal_id = string
    role         = string
    scope        = string
  }))
  default = []
}
