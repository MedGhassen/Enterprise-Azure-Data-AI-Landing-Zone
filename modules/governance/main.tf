# Management group hierarchy (CAF-aligned):
#   <parent> -> Platform     -> Management, Connectivity, Identity (optional)
#            -> Landing Zones -> Data & AI Dev, Staging, Prod
#            -> Sandbox
# Deploy this module ONCE per tenant (see platform/), never per environment.
data "azurerm_client_config" "current" {}

locals {
  mg_parent_id = coalesce(var.management_group_parent_id, "/providers/Microsoft.Management/managementGroups/${data.azurerm_client_config.current.tenant_id}")
  p            = var.management_group_prefix
}

resource "azurerm_management_group" "platform" {
  name                       = "${local.p}-platform"
  display_name               = "Platform"
  parent_management_group_id = local.mg_parent_id
}

resource "azurerm_management_group" "landing_zones" {
  name                       = "${local.p}-landingzones"
  display_name               = "Landing Zones"
  parent_management_group_id = local.mg_parent_id
}

resource "azurerm_management_group" "sandbox" {
  name                       = "${local.p}-sandbox"
  display_name               = "Sandbox"
  parent_management_group_id = local.mg_parent_id
}

resource "azurerm_management_group" "management" {
  name                       = "${local.p}-management"
  display_name               = "Management"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "connectivity" {
  name                       = "${local.p}-connectivity"
  display_name               = "Connectivity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "identity" {
  count                      = var.create_identity_management_group ? 1 : 0
  name                       = "${local.p}-identity"
  display_name               = "Identity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "data_ai" {
  for_each                   = toset(["dev", "staging", "prod"])
  name                       = "${local.p}-dataai-${each.key}"
  display_name               = "Data & AI - ${title(each.key)}"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

# ---------------------------------------------------------------------------
# Subscription placement
# ---------------------------------------------------------------------------
locals {
  mg_ids = merge(
    {
      platform      = azurerm_management_group.platform.id
      landing_zones = azurerm_management_group.landing_zones.id
      sandbox       = azurerm_management_group.sandbox.id
      management    = azurerm_management_group.management.id
      connectivity  = azurerm_management_group.connectivity.id
    },
    var.create_identity_management_group ? { identity = azurerm_management_group.identity[0].id } : {},
    { for k, mg in azurerm_management_group.data_ai : "dataai_${k}" => mg.id },
  )
}

resource "azurerm_management_group_subscription_association" "this" {
  for_each            = { for k, sub in var.subscription_placement : k => sub if sub != null && sub != "" }
  management_group_id = local.mg_ids[each.key]
  subscription_id     = "/subscriptions/${each.value}"
}

# ---------------------------------------------------------------------------
# Baseline policy assignments on Landing Zones
# ---------------------------------------------------------------------------
data "azurerm_policy_definition" "allowed_locations" {
  display_name = "Allowed locations"
}

data "azurerm_policy_definition" "require_rg_tag" {
  display_name = "Require a tag on resource groups"
}

data "azurerm_policy_definition" "inherit_rg_tag" {
  display_name = "Inherit a tag from the resource group if missing"
}

resource "azurerm_management_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  display_name         = "Allowed locations"
  management_group_id  = azurerm_management_group.landing_zones.id
  policy_definition_id = data.azurerm_policy_definition.allowed_locations.id
  parameters           = jsonencode({ listOfAllowedLocations = { value = var.allowed_locations } })
}

# Deny resource groups without the required tags...
resource "azurerm_management_group_policy_assignment" "require_rg_tag" {
  for_each             = toset(var.required_tags)
  name                 = substr("req-rg-tag-${replace(each.key, "_", "-")}", 0, 24)
  display_name         = "Require tag '${each.key}' on resource groups"
  management_group_id  = azurerm_management_group.landing_zones.id
  policy_definition_id = data.azurerm_policy_definition.require_rg_tag.id
  parameters           = jsonencode({ tagName = { value = each.key } })
}

# ...and copy them down to resources (also covers service-managed resource groups).
resource "azurerm_management_group_policy_assignment" "inherit_rg_tag" {
  for_each             = toset(var.required_tags)
  name                 = substr("inh-rg-tag-${replace(each.key, "_", "-")}", 0, 24)
  display_name         = "Inherit tag '${each.key}' from resource group"
  management_group_id  = azurerm_management_group.landing_zones.id
  policy_definition_id = data.azurerm_policy_definition.inherit_rg_tag.id
  parameters           = jsonencode({ tagName = { value = each.key } })
  location             = var.policy_identity_location

  identity {
    type = "SystemAssigned"
  }
}

# Modify policies need Tag Contributor to remediate.
resource "azurerm_role_assignment" "inherit_rg_tag" {
  for_each             = azurerm_management_group_policy_assignment.inherit_rg_tag
  scope                = azurerm_management_group.landing_zones.id
  role_definition_name = "Tag Contributor"
  principal_id         = each.value.identity[0].principal_id
}

# ---------------------------------------------------------------------------
# Regulatory compliance initiatives (audit). Assignments get a managed identity
# because some initiatives contain DeployIfNotExists/Modify policies.
# ---------------------------------------------------------------------------
data "azurerm_policy_set_definition" "iso27001" {
  count        = var.enable_iso27001 ? 1 : 0
  display_name = "ISO 27001:2013"
}

locals {
  compliance_assignments = merge(
    var.enable_iso27001 ? {
      "compliance-iso27001" = {
        display_name             = "ISO 27001:2013"
        policy_set_definition_id = data.azurerm_policy_set_definition.iso27001[0].id
        scope                    = var.compliance_policy_scope
        parameters               = var.compliance_policy_parameters_iso27001
      }
    } : {},
    var.enable_nis2 ? {
      "compliance-nis2" = {
        display_name             = "NIS2"
        policy_set_definition_id = var.nis2_initiative_id
        scope                    = var.compliance_policy_scope
        parameters               = var.compliance_policy_parameters_nis2
      }
    } : {},
    {
      for a in var.compliance_policy_assignments : a.assignment_name => {
        display_name             = coalesce(a.display_name, a.assignment_name)
        policy_set_definition_id = a.policy_set_definition_id
        scope                    = a.assignment_scope
        parameters               = a.parameters
      } if a.enable
    },
  )
}

resource "azurerm_management_group_policy_assignment" "compliance" {
  for_each             = local.compliance_assignments
  name                 = each.key
  display_name         = each.value.display_name
  management_group_id  = local.mg_ids[each.value.scope]
  policy_definition_id = each.value.policy_set_definition_id
  parameters           = each.value.parameters
  enforce              = true
  location             = var.policy_identity_location

  identity {
    type = "SystemAssigned"
  }
}

# ---------------------------------------------------------------------------
# Custom RBAC roles + role assignments
# ---------------------------------------------------------------------------
locals {
  default_custom_roles = var.create_default_custom_roles ? [
    {
      name        = "${var.custom_role_name_prefix} Data Engineer"
      description = "Build and run data pipelines (ADF, Synapse, Databricks, Event Hubs) and read/write the data lake."
      actions = [
        "Microsoft.DataFactory/*",
        "Microsoft.Synapse/workspaces/read",
        "Microsoft.Synapse/workspaces/sparkPools/read",
        "Microsoft.Synapse/workspaces/sqlPools/read",
        "Microsoft.Databricks/workspaces/read",
        "Microsoft.EventHub/namespaces/read",
        "Microsoft.EventHub/namespaces/eventhubs/*",
        "Microsoft.StreamAnalytics/streamingjobs/*",
        "Microsoft.Storage/storageAccounts/read",
        "Microsoft.Storage/storageAccounts/blobServices/containers/read",
        "Microsoft.Resources/subscriptions/resourceGroups/read",
        "Microsoft.Insights/*/read",
      ]
      not_actions = ["Microsoft.DataFactory/factories/delete"]
      data_actions = [
        "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/*",
        "Microsoft.EventHub/namespaces/messages/*",
      ]
    },
    {
      name        = "${var.custom_role_name_prefix} Data Scientist"
      description = "Use Azure ML, Foundry projects and Databricks; read curated data and query AI Search."
      actions = [
        "Microsoft.MachineLearningServices/workspaces/*/read",
        "Microsoft.MachineLearningServices/workspaces/experiments/*",
        "Microsoft.MachineLearningServices/workspaces/jobs/*",
        "Microsoft.MachineLearningServices/workspaces/computes/start/action",
        "Microsoft.MachineLearningServices/workspaces/computes/stop/action",
        "Microsoft.MachineLearningServices/workspaces/notebooks/*",
        "Microsoft.CognitiveServices/accounts/read",
        "Microsoft.CognitiveServices/accounts/projects/read",
        "Microsoft.Databricks/workspaces/read",
        "Microsoft.Search/searchServices/read",
        "Microsoft.Storage/storageAccounts/read",
        "Microsoft.Resources/subscriptions/resourceGroups/read",
        "Microsoft.Insights/*/read",
      ]
      not_actions = []
      data_actions = [
        "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
        "Microsoft.CognitiveServices/accounts/OpenAI/*",
        "Microsoft.CognitiveServices/accounts/AIServices/*",
        "Microsoft.Search/searchServices/indexes/documents/read",
      ]
    },
    {
      name        = "${var.custom_role_name_prefix} ML Engineer"
      description = "Operate ML/AI workloads: Azure ML endpoints and computes, Foundry deployments, AKS and ACR."
      actions = [
        "Microsoft.MachineLearningServices/workspaces/*",
        "Microsoft.CognitiveServices/accounts/read",
        "Microsoft.CognitiveServices/accounts/deployments/*",
        "Microsoft.CognitiveServices/accounts/projects/*",
        "Microsoft.ContainerService/managedClusters/read",
        "Microsoft.ContainerService/managedClusters/listClusterUserCredential/action",
        "Microsoft.ContainerRegistry/registries/read",
        "Microsoft.Resources/subscriptions/resourceGroups/read",
        "Microsoft.Insights/*/read",
      ]
      not_actions = ["Microsoft.MachineLearningServices/workspaces/delete"]
      data_actions = [
        "Microsoft.CognitiveServices/accounts/OpenAI/*",
        "Microsoft.CognitiveServices/accounts/AIServices/*",
        "Microsoft.ContainerRegistry/registries/repositories/*",
      ]
    },
  ] : []

  custom_roles = { for r in concat(local.default_custom_roles, var.custom_roles) : r.name => r }
}

resource "azurerm_role_definition" "custom" {
  for_each    = local.custom_roles
  name        = each.value.name
  scope       = azurerm_management_group.landing_zones.id
  description = each.value.description

  permissions {
    actions          = each.value.actions
    not_actions      = each.value.not_actions
    data_actions     = each.value.data_actions
    not_data_actions = []
  }

  assignable_scopes = [azurerm_management_group.landing_zones.id]
}

resource "azurerm_role_assignment" "this" {
  for_each             = { for ra in var.role_assignments : "${ra.principal_id}|${ra.role}|${ra.scope}" => ra }
  scope                = lookup(local.mg_ids, each.value.scope, each.value.scope)
  role_definition_id   = try(azurerm_role_definition.custom[each.value.role].role_definition_resource_id, null)
  role_definition_name = contains(keys(local.custom_roles), each.value.role) ? null : each.value.role
  principal_id         = each.value.principal_id
}
