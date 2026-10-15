# ---------------------------------------------------------------------------
# Microsoft Foundry: AI Services account (models, agents, speech, vision, language)
# with project management enabled, Foundry projects and model deployments.
# ---------------------------------------------------------------------------
locals {
  foundry_name = "${var.name_prefix}-aif-${var.unique_suffix}-${var.name_suffix}"
  foundry_dns_zones = [
    "privatelink.cognitiveservices.azure.com",
    "privatelink.openai.azure.com",
    "privatelink.services.ai.azure.com",
  ]
}

resource "azurerm_cognitive_account" "foundry" {
  count                         = var.enable_foundry ? 1 : 0
  name                          = local.foundry_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  kind                          = "AIServices"
  sku_name                      = "S0"
  custom_subdomain_name         = local.foundry_name
  local_auth_enabled            = false
  public_network_access_enabled = false
  project_management_enabled    = true
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

resource "azurerm_cognitive_account_project" "projects" {
  for_each             = var.enable_foundry ? { for p in var.foundry_projects : p.name => p } : {}
  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.foundry[0].id
  location             = var.location
  display_name         = each.value.display_name
  description          = each.value.description
  tags                 = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_cognitive_deployment" "models" {
  for_each               = var.enable_foundry ? { for d in var.model_deployments : d.name => d } : {}
  name                   = each.value.name
  cognitive_account_id   = azurerm_cognitive_account.foundry[0].id
  version_upgrade_option = "OnceNewDefaultVersionAvailable"

  model {
    format  = each.value.format
    name    = each.value.model
    version = each.value.version
  }

  sku {
    name     = each.value.sku_name
    capacity = each.value.capacity
  }
}

resource "azurerm_private_endpoint" "foundry" {
  count               = var.enable_foundry ? 1 : 0
  name                = "${var.name_prefix}-aif-pe-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "aif-psc"
    private_connection_resource_id = azurerm_cognitive_account.foundry[0].id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [for z in local.foundry_dns_zones : var.private_dns_zone_ids[z]]
  }
}

resource "azurerm_monitor_diagnostic_setting" "foundry" {
  count                      = var.enable_foundry ? 1 : 0
  name                       = "diag-to-law"
  target_resource_id         = azurerm_cognitive_account.foundry[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}

# ---------------------------------------------------------------------------
# Foundry <-> AI Search integration (keyless, managed identities)
# ---------------------------------------------------------------------------
resource "azurerm_cognitive_account_connection_entra_id" "search" {
  count                = var.enable_foundry && var.enable_search ? 1 : 0
  name                 = "ai-search"
  cognitive_account_id = azurerm_cognitive_account.foundry[0].id
  category             = "CognitiveSearch"
  target               = "https://${azurerm_search_service.main[0].name}.search.windows.net"
  metadata = {
    ApiType    = "Azure"
    ResourceId = azurerm_search_service.main[0].id
    location   = var.location
  }
}

locals {
  # Foundry account + project identities that read/write search indexes.
  search_clients = var.enable_foundry && var.enable_search ? merge(
    { account = azurerm_cognitive_account.foundry[0].identity[0].principal_id },
    { for k, p in azurerm_cognitive_account_project.projects : "project-${k}" => p.identity[0].principal_id },
  ) : {}
  search_client_roles = {
    for pair in setproduct(keys(local.search_clients), ["Search Index Data Contributor", "Search Service Contributor"]) :
    "${pair[0]}|${pair[1]}" => { principal = pair[0], role = pair[1] }
  }
}

resource "azurerm_role_assignment" "foundry_search" {
  for_each             = local.search_client_roles
  scope                = azurerm_search_service.main[0].id
  role_definition_name = each.value.role
  principal_id         = local.search_clients[each.value.principal]
}

# AI Search identity calls embedding models for integrated vectorization.
resource "azurerm_role_assignment" "search_foundry" {
  count                = var.enable_foundry && var.enable_search ? 1 : 0
  scope                = azurerm_cognitive_account.foundry[0].id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_search_service.main[0].identity[0].principal_id
}
