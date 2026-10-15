data "azurerm_client_config" "current" {}

resource "azurerm_data_factory" "main" {
  name                = "${var.name_prefix}-adf-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  tags                = var.tags

  managed_virtual_network_enabled = true
  public_network_enabled          = false

  identity {
    type = "SystemAssigned"
  }

  dynamic "github_configuration" {
    for_each = var.git_repo_type == "GitHub" && var.git_repo_url != "" ? [1] : []
    content {
      account_name    = split("/", var.git_repo_url)[3]
      repository_name = split("/", var.git_repo_url)[4]
      branch_name     = var.git_branch
      root_folder     = var.git_root_folder
    }
  }

  dynamic "vsts_configuration" {
    for_each = var.git_repo_type == "AzureDevOpsGit" && var.git_repo_url != "" ? [1] : []
    content {
      account_name    = split("/", var.git_repo_url)[3]
      project_name    = split("/", var.git_repo_url)[4]
      repository_name = split("/", var.git_repo_url)[5]
      branch_name     = var.git_branch
      root_folder     = var.git_root_folder
      tenant_id       = data.azurerm_client_config.current.tenant_id
    }
  }
}

resource "azurerm_data_factory_managed_private_endpoint" "targets" {
  for_each           = { for pe in var.managed_private_endpoint_targets : pe.name => pe }
  name               = "pe-${each.key}"
  data_factory_id    = azurerm_data_factory.main.id
  target_resource_id = each.value.target_resource_id
  subresource_name   = each.value.subresource_name
}

resource "azurerm_monitor_diagnostic_setting" "adf" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "adf-diag"
  target_resource_id         = azurerm_data_factory.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log { category = "ActivityRuns" }
  enabled_log { category = "PipelineRuns" }
  enabled_log { category = "TriggerRuns" }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
