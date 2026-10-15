# Tenant-level governance for the Data & AI landing zones. Deploy ONCE per tenant,
# before the per-environment landing zone stack in the repository root.
module "governance" {
  source = "../modules/governance"

  management_group_prefix          = var.management_group_prefix
  management_group_parent_id       = var.management_group_parent_id
  create_identity_management_group = var.create_identity_management_group
  subscription_placement           = var.subscription_placement
  allowed_locations                = var.allowed_locations
  required_tags                    = var.required_tags
  policy_identity_location         = var.policy_identity_location
  enable_iso27001                  = var.enable_iso27001
  enable_nis2                      = var.enable_nis2
  nis2_initiative_id               = var.nis2_initiative_id
  compliance_policy_scope          = var.compliance_policy_scope
  compliance_policy_assignments    = var.compliance_policy_assignments
  create_default_custom_roles      = var.create_default_custom_roles
  role_assignments                 = var.role_assignments
}
