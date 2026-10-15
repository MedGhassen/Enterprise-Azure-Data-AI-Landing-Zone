locals {
  # https://github.com/<owner>/<repo> or https://dev.azure.com/<org>/<project>/_git/<repo>
  git_parts = var.git_repo_url != null ? split("/", trimprefix(trimprefix(var.git_repo_url, "https://"), "http://")) : []
}

resource "azurerm_data_factory" "main" {
  name                            = "${var.name_prefix}-adf-${var.unique_suffix}-${var.name_suffix}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  managed_virtual_network_enabled = true
  public_network_enabled          = false
  tags                            = var.tags

  identity {
    type = "SystemAssigned"
  }

  dynamic "github_configuration" {
    for_each = var.git_repo_type == "GitHub" && var.git_repo_url != null ? [1] : []
    content {
      account_name    = local.git_parts[1]
      repository_name = local.git_parts[2]
      branch_name     = var.git_branch
      root_folder     = var.git_root_folder
      git_url         = "https://github.com"
    }
  }

  dynamic "vsts_configuration" {
    for_each = var.git_repo_type == "AzureDevOpsGit" && var.git_repo_url != null ? [1] : []
    content {
      account_name    = local.git_parts[1]
      project_name    = local.git_parts[2]
      repository_name = local.git_parts[4]
      branch_name     = var.git_branch
      root_folder     = var.git_root_folder
      tenant_id       = var.tenant_id
    }
  }
}

# Managed private endpoints from the ADF managed VNet to the data lake.
# NOTE: these connections must be approved on the target storage account
# (Networking > Private endpoint connections) before they can be used.
resource "azurerm_data_factory_managed_private_endpoint" "lake" {
  for_each           = toset(["dfs", "blob"])
  name               = "mpe-lake-${each.key}"
  data_factory_id    = azurerm_data_factory.main.id
  target_resource_id = var.storage_account_id
  subresource_name   = each.key
}

# ADF managed identity can read/write the lake.
resource "azurerm_role_assignment" "lake" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.main.identity[0].principal_id
}

# Private endpoints for the ADF service (self-hosted IR / authoring) and portal.
locals {
  adf_endpoints = {
    dataFactory = "privatelink.datafactory.azure.net"
    portal      = "privatelink.adf.azure.com"
  }
}

resource "azurerm_private_endpoint" "adf" {
  for_each            = local.adf_endpoints
  name                = "${var.name_prefix}-adf-${lower(each.key)}-pe-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "adf-${lower(each.key)}-psc"
    private_connection_resource_id = azurerm_data_factory.main.id
    subresource_names              = [each.key]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids[each.value]]
  }
}

resource "azurerm_monitor_diagnostic_setting" "adf" {
  name                           = "diag-to-law"
  target_resource_id             = azurerm_data_factory.main.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category_group = "allLogs"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}
