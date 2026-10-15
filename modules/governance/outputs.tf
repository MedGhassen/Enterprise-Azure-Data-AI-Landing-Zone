output "management_group_platform_id" {
  description = "Platform management group ID"
  value       = try(azurerm_management_group.platform[0].id, null)
}

output "management_group_landing_zones_id" {
  description = "Landing Zones management group ID"
  value       = try(azurerm_management_group.landing_zones[0].id, null)
}

output "management_group_sandbox_id" {
  description = "Sandbox (top-level) management group ID"
  value       = try(azurerm_management_group.sandbox[0].id, null)
}

output "management_group_management_id" {
  description = "Platform/Management child management group ID"
  value       = try(azurerm_management_group.management[0].id, null)
}

output "management_group_connectivity_id" {
  description = "Platform/Connectivity child management group ID"
  value       = try(azurerm_management_group.connectivity[0].id, null)
}

output "management_group_identity_id" {
  description = "Platform/Identity child management group ID"
  value       = try(azurerm_management_group.identity[0].id, null)
}

output "management_group_data_ai_dev_id" {
  description = "Landing Zones/Data & AI Dev child management group ID"
  value       = try(azurerm_management_group.data_ai_dev[0].id, null)
}

output "management_group_data_ai_staging_id" {
  description = "Landing Zones/Data & AI Staging child management group ID"
  value       = try(azurerm_management_group.data_ai_staging[0].id, null)
}

output "management_group_data_ai_prod_id" {
  description = "Landing Zones/Data & AI Prod child management group ID"
  value       = try(azurerm_management_group.data_ai_prod[0].id, null)
}

output "management_group_sandbox_child_id" {
  description = "Sandbox child management group ID (for sandbox subscription)"
  value       = try(azurerm_management_group.sandbox_child[0].id, null)
}

output "custom_role_definition_ids" {
  description = "Map of custom role definition IDs by name"
  value       = { for k, r in azurerm_role_definition.custom : k => r.id }
}

output "policy_assignment_ids" {
  description = "Policy assignment resource IDs"
  value = concat(
    try(azurerm_management_group_policy_assignment.allowed_locations[*].id, []),
    try(azurerm_management_group_policy_assignment.require_tag_environment[*].id, []),
    try(azurerm_management_group_policy_assignment.require_tag_cost_center[*].id, []),
    try(azurerm_management_group_policy_assignment.compliance_iso27001[*].id, []),
    try(azurerm_management_group_policy_assignment.compliance_nis2[*].id, []),
    [for a in azurerm_management_group_policy_assignment.compliance_custom : a.id]
  )
}
