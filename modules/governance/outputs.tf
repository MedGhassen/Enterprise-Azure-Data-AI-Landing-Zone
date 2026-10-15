output "management_group_ids" {
  description = "Management group IDs keyed by role (platform, landing_zones, sandbox, management, connectivity, identity, dataai_dev, dataai_staging, dataai_prod)."
  value       = local.mg_ids
}

output "custom_role_definition_ids" {
  description = "Custom role definition resource IDs keyed by role name."
  value       = { for k, r in azurerm_role_definition.custom : k => r.role_definition_resource_id }
}

output "policy_assignment_ids" {
  description = "Policy assignment IDs keyed by assignment name."
  value = merge(
    { (azurerm_management_group_policy_assignment.allowed_locations.name) = azurerm_management_group_policy_assignment.allowed_locations.id },
    { for k, a in azurerm_management_group_policy_assignment.require_rg_tag : a.name => a.id },
    { for k, a in azurerm_management_group_policy_assignment.inherit_rg_tag : a.name => a.id },
    { for k, a in azurerm_management_group_policy_assignment.compliance : k => a.id },
  )
}
