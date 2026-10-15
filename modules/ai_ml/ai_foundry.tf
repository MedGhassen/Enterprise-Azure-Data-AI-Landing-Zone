# Azure AI Foundry (Hub + Projects) via azapi - Microsoft.MachineLearningServices/workspaces with kind Hub/Project
data "azurerm_client_config" "current" {}

# AI Foundry Hub (azapi - kind = Hub)
resource "azapi_resource" "ai_foundry_hub" {
  type      = "Microsoft.MachineLearningServices/workspaces@2024-04-01"
  name      = substr("${var.name_prefix}-aifhub", 0, 33)
  location  = var.primary_region
  parent_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  tags      = var.tags

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    kind = "Hub"
    sku = {
      name = "Basic"
      tier = "Basic"
    }
    properties = {
      description         = "Azure AI Foundry Hub"
      keyVault            = var.key_vault_id
      storageAccount      = azurerm_storage_account.ml.id
      applicationInsights = var.application_insights_id
      publicNetworkAccess = "Disabled"
      managedNetwork = {
        isolationMode = "AllowInternetOutbound"
      }
    }
  })
}

data "azurerm_machine_learning_workspace" "hub" {
  name                = azapi_resource.ai_foundry_hub.name
  resource_group_name = var.resource_group_name
  depends_on          = [azapi_resource.ai_foundry_hub]
}

# AI Foundry Projects (kind = Project)
resource "azapi_resource" "ai_foundry_project" {
  for_each  = { for p in var.ai_foundry_projects : p.name => p }
  type      = "Microsoft.MachineLearningServices/workspaces@2024-04-01"
  name      = substr("${var.name_prefix}-aif-${each.value.name}", 0, 33)
  location  = var.primary_region
  parent_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  tags      = var.tags

  identity {
    type = "SystemAssigned"
  }

  body = jsonencode({
    kind = "Project"
    properties = {
      description   = each.value.display_name
      hubResourceId = azapi_resource.ai_foundry_hub.id
    }
  })
}

# Role: Hub managed identity -> OpenAI Contributor on OpenAI resource
resource "azurerm_role_assignment" "hub_openai" {
  scope                = azurerm_cognitive_account.openai.id
  role_definition_name = "Cognitive Services OpenAI Contributor"
  principal_id         = data.azurerm_machine_learning_workspace.hub.identity[0].principal_id
}

# Role: Hub managed identity -> Search Index Data Contributor on AI Search
resource "azurerm_role_assignment" "hub_search" {
  scope                = azurerm_search_service.main.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = data.azurerm_machine_learning_workspace.hub.identity[0].principal_id
}
