output "management_group_ids" {
  description = "Management group IDs keyed by role."
  value       = module.governance.management_group_ids
}

output "custom_role_definition_ids" {
  description = "Custom role definition IDs keyed by name."
  value       = module.governance.custom_role_definition_ids
}

output "policy_assignment_ids" {
  description = "Policy assignment IDs keyed by name."
  value       = module.governance.policy_assignment_ids
}
