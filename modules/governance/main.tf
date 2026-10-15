# Management group hierarchy: Tenant Root -> Platform | Landing Zones | Sandbox (siblings)
# Platform -> Management, Connectivity, Identity (optional)
# Landing Zones -> Data & AI Dev, Data & AI Staging, Data & AI Prod
# Sandbox -> Sandbox (child)
data "azurerm_client_config" "current" {}

locals {
  tenant_root_id = "/providers/Microsoft.Management/managementGroups/${data.azurerm_client_config.current.tenant_id}"
  mg_parent_id   = var.management_group_parent_id != "" ? var.management_group_parent_id : local.tenant_root_id
}

# Top-level: Platform, Landing Zones, Sandbox as siblings under tenant root
resource "azurerm_management_group" "platform" {
  count                      = var.create_management_group_hierarchy ? 1 : 0
  display_name               = "Platform"
  parent_management_group_id = local.mg_parent_id
  subscription_ids           = []
}

resource "azurerm_management_group" "landing_zones" {
  count                      = var.create_management_group_hierarchy ? 1 : 0
  display_name               = "Landing Zones"
  parent_management_group_id = local.mg_parent_id
  subscription_ids           = []
}

resource "azurerm_management_group" "sandbox" {
  count                      = var.create_management_group_hierarchy ? 1 : 0
  display_name               = "Sandbox"
  parent_management_group_id = local.mg_parent_id
  subscription_ids           = []
}

# Platform children: Management, Connectivity, Identity (optional)
resource "azurerm_management_group" "management" {
  count                      = var.create_management_group_hierarchy ? 1 : 0
  display_name               = "Management"
  parent_management_group_id = azurerm_management_group.platform[0].id
  subscription_ids           = []
}

resource "azurerm_management_group" "connectivity" {
  count                      = var.create_management_group_hierarchy ? 1 : 0
  display_name               = "Connectivity"
  parent_management_group_id = azurerm_management_group.platform[0].id
  subscription_ids           = []
}

resource "azurerm_management_group" "identity" {
  count                      = var.create_management_group_hierarchy && var.create_identity_management_group ? 1 : 0
  display_name               = "Identity"
  parent_management_group_id = azurerm_management_group.platform[0].id
  subscription_ids           = []
}

# Landing Zones children: Data & AI Dev, Staging, Prod
resource "azurerm_management_group" "data_ai_dev" {
  count                      = var.create_management_group_hierarchy ? 1 : 0
  display_name               = "Data & AI — Dev"
  parent_management_group_id = azurerm_management_group.landing_zones[0].id
  subscription_ids           = []
}

resource "azurerm_management_group" "data_ai_staging" {
  count                      = var.create_management_group_hierarchy ? 1 : 0
  display_name               = "Data & AI — Staging"
  parent_management_group_id = azurerm_management_group.landing_zones[0].id
  subscription_ids           = []
}

resource "azurerm_management_group" "data_ai_prod" {
  count                      = var.create_management_group_hierarchy ? 1 : 0
  display_name               = "Data & AI — Prod"
  parent_management_group_id = azurerm_management_group.landing_zones[0].id
  subscription_ids           = []
}

# Sandbox child
resource "azurerm_management_group" "sandbox_child" {
  count                      = var.create_management_group_hierarchy ? 1 : 0
  display_name               = "Sandbox"
  parent_management_group_id = azurerm_management_group.sandbox[0].id
  subscription_ids           = []
}

# Subscription associations (legacy: single subscription on Landing Zones parent)
resource "azurerm_management_group_subscription_association" "landing_zones" {
  count               = var.create_management_group_hierarchy && var.subscription_id != "" ? 1 : 0
  management_group_id = azurerm_management_group.landing_zones[0].id
  subscription_id     = "/subscriptions/${var.subscription_id}"
}

# Subscription associations: Platform
resource "azurerm_management_group_subscription_association" "connectivity" {
  count               = var.create_management_group_hierarchy && var.subscription_id_connectivity != "" ? 1 : 0
  management_group_id = azurerm_management_group.connectivity[0].id
  subscription_id     = "/subscriptions/${var.subscription_id_connectivity}"
}

resource "azurerm_management_group_subscription_association" "management" {
  count               = var.create_management_group_hierarchy && var.subscription_id_management != "" ? 1 : 0
  management_group_id = azurerm_management_group.management[0].id
  subscription_id     = "/subscriptions/${var.subscription_id_management}"
}

resource "azurerm_management_group_subscription_association" "identity" {
  count               = var.create_management_group_hierarchy && var.create_identity_management_group && var.subscription_id_identity != "" ? 1 : 0
  management_group_id = azurerm_management_group.identity[0].id
  subscription_id     = "/subscriptions/${var.subscription_id_identity}"
}

# Subscription associations: Landing Zones (Data & AI)
resource "azurerm_management_group_subscription_association" "data_ai_dev" {
  count               = var.create_management_group_hierarchy && var.subscription_id_dataai_dev != "" ? 1 : 0
  management_group_id = azurerm_management_group.data_ai_dev[0].id
  subscription_id     = "/subscriptions/${var.subscription_id_dataai_dev}"
}

resource "azurerm_management_group_subscription_association" "data_ai_staging" {
  count               = var.create_management_group_hierarchy && var.subscription_id_dataai_staging != "" ? 1 : 0
  management_group_id = azurerm_management_group.data_ai_staging[0].id
  subscription_id     = "/subscriptions/${var.subscription_id_dataai_staging}"
}

resource "azurerm_management_group_subscription_association" "data_ai_prod" {
  count               = var.create_management_group_hierarchy && var.subscription_id_dataai_prod != "" ? 1 : 0
  management_group_id = azurerm_management_group.data_ai_prod[0].id
  subscription_id     = "/subscriptions/${var.subscription_id_dataai_prod}"
}

# Subscription association: Sandbox
resource "azurerm_management_group_subscription_association" "sandbox" {
  count               = var.create_management_group_hierarchy && var.subscription_id_sandbox != "" ? 1 : 0
  management_group_id = azurerm_management_group.sandbox_child[0].id
  subscription_id     = "/subscriptions/${var.subscription_id_sandbox}"
}

# Resolve target management group for compliance policy assignments
locals {
  compliance_scope_mg_id = var.create_management_group_hierarchy ? (
    var.compliance_policy_scope_mg == "platform" ? azurerm_management_group.platform[0].id :
    var.compliance_policy_scope_mg == "sandbox" ? azurerm_management_group.sandbox[0].id :
    azurerm_management_group.landing_zones[0].id
  ) : null
}

# Compliance initiatives (policy set definitions): ISO 27001, NIS2
data "azurerm_policy_set_definition" "iso27001" {
  count        = var.create_management_group_hierarchy && var.enable_iso27001 ? 1 : 0
  display_name = "ISO 27001:2013"
}

# NIS2: use custom/partner initiative ID from variable (no built-in)
resource "azurerm_management_group_policy_assignment" "compliance_iso27001" {
  count                = var.create_management_group_hierarchy && var.enable_iso27001 ? 1 : 0
  name                 = "compliance-iso27001"
  management_group_id  = local.compliance_scope_mg_id
  policy_definition_id = data.azurerm_policy_set_definition.iso27001[0].id
  display_name         = "ISO 27001:2013"
  parameters           = var.compliance_policy_parameters_iso27001 != "{}" ? var.compliance_policy_parameters_iso27001 : "{}"
}

resource "azurerm_management_group_policy_assignment" "compliance_nis2" {
  count                = var.create_management_group_hierarchy && var.enable_nis2 && var.nis2_initiative_id != "" ? 1 : 0
  name                 = "compliance-nis2"
  management_group_id  = local.compliance_scope_mg_id
  policy_definition_id = var.nis2_initiative_id
  display_name         = "NIS2"
  parameters           = var.compliance_policy_parameters_nis2 != "{}" ? var.compliance_policy_parameters_nis2 : "{}"
}

# Optional: additional compliance initiatives via compliance_policy_assignments list
locals {
  compliance_custom_keys            = { for i, a in var.compliance_policy_assignments : (try(a.assignment_name, "") != "" ? a.assignment_name : "compliance-${i}") => merge(a, { key = try(a.assignment_name, "") != "" ? a.assignment_name : "compliance-${i}" }) if a.enable && (try(a.initiative_display_name, "") != "" || try(a.policy_set_definition_id, "") != "") }
  compliance_custom_by_display_name = { for k, a in local.compliance_custom_keys : k => a if try(a.initiative_display_name, "") != "" }
}

data "azurerm_policy_set_definition" "compliance_custom" {
  for_each     = var.create_management_group_hierarchy ? local.compliance_custom_by_display_name : {}
  display_name = each.value.initiative_display_name
}

resource "azurerm_management_group_policy_assignment" "compliance_custom" {
  for_each = var.create_management_group_hierarchy ? local.compliance_custom_keys : {}

  name = replace(each.value.key, " ", "-")
  management_group_id = (
    try(each.value.assignment_scope, "landing_zones") == "platform" ? azurerm_management_group.platform[0].id :
    try(each.value.assignment_scope, "landing_zones") == "sandbox" ? azurerm_management_group.sandbox[0].id :
    azurerm_management_group.landing_zones[0].id
  )
  policy_definition_id = contains(keys(data.azurerm_policy_set_definition.compliance_custom), each.key) ? data.azurerm_policy_set_definition.compliance_custom[each.key].id : each.value.policy_set_definition_id
  display_name         = try(each.value.initiative_display_name, "Compliance initiative")
  parameters           = try(each.value.parameters, "{}")
}

# Built-in policy definitions (by name) - we use ARM template IDs for assignments
data "azurerm_policy_definition" "allowed_locations" {
  count        = length(var.policy_assignments) > 0 ? 0 : (var.create_management_group_hierarchy ? 1 : 0)
  display_name = "Allowed locations"
}

data "azurerm_policy_definition" "require_tag" {
  count        = length(var.policy_assignments) > 0 ? 0 : (var.create_management_group_hierarchy ? 1 : 0)
  display_name = "Require a tag and its value on resources"
}

# Default policy assignments (use built-in definitions by display name) at Landing Zones level when no custom list provided
resource "azurerm_management_group_policy_assignment" "allowed_locations" {
  count                = var.create_management_group_hierarchy && length(var.policy_assignments) == 0 ? 1 : 0
  name                 = "allowed-locations"
  management_group_id  = azurerm_management_group.landing_zones[0].id
  policy_definition_id = data.azurerm_policy_definition.allowed_locations[0].id
  display_name         = "Allowed locations"
  parameters           = jsonencode({ listOfAllowedLocations = { value = var.allowed_locations } })
}

resource "azurerm_management_group_policy_assignment" "require_tag_environment" {
  count                = var.create_management_group_hierarchy && length(var.policy_assignments) == 0 ? 1 : 0
  name                 = "require-tag-environment"
  management_group_id  = azurerm_management_group.landing_zones[0].id
  policy_definition_id = data.azurerm_policy_definition.require_tag[0].id
  display_name         = "Require environment tag"
  parameters           = jsonencode({ tagName = { value = "environment" }, tagValue = { value = "*" } })
}

resource "azurerm_management_group_policy_assignment" "require_tag_cost_center" {
  count                = var.create_management_group_hierarchy && length(var.policy_assignments) == 0 ? 1 : 0
  name                 = "require-tag-cost-center"
  management_group_id  = azurerm_management_group.landing_zones[0].id
  policy_definition_id = data.azurerm_policy_definition.require_tag[0].id
  display_name         = "Require cost-center tag"
  parameters           = jsonencode({ tagName = { value = "cost_center" }, tagValue = { value = "*" } })
}

# Custom RBAC role definitions
resource "azurerm_role_definition" "custom" {
  for_each = { for r in var.custom_roles : r.name => r }

  name        = each.value.name
  scope       = each.value.scope
  description = each.value.description

  permissions {
    actions     = each.value.actions
    not_actions = []
  }

  assignable_scopes = each.value.assignable_scopes
}

# Role assignments (built-in or custom)
data "azurerm_subscription" "primary" {
  count = length(var.role_assignments) > 0 ? 1 : 0
}

locals {
  role_id_map = {
    "Reader"                        = "/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
    "Contributor"                   = "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
    "Storage Blob Data Contributor" = "/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe"
  }
  role_assignments_with_id = [for ra in var.role_assignments : merge(ra, {
    role_definition_id = ra.role_definition_id != null ? ra.role_definition_id : (ra.role_definition_name != null ? local.role_id_map[ra.role_definition_name] : null)
  })]
}

resource "azurerm_role_assignment" "assignment" {
  for_each = { for i, ra in local.role_assignments_with_id : i => ra if ra.role_definition_id != null && ra.principal_id != "" }

  scope                            = each.value.scope
  role_definition_id               = each.value.role_definition_id
  principal_id                     = each.value.principal_id
  skip_service_principal_aad_check = true
}
