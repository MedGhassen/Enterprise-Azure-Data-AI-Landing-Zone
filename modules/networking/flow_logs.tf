# ---------------------------------------------------------------------------
# VNet flow logs + Traffic Analytics (NSG flow logs are retired for new deployments).
# Azure creates one Network Watcher per region automatically (NetworkWatcherRG);
# set create_network_watcher = true only if that auto-creation is disabled.
# ---------------------------------------------------------------------------
locals {
  flow_log_vnets = var.enable_flow_logs ? {
    hub   = azurerm_virtual_network.hub.id
    spoke = azurerm_virtual_network.spoke.id
  } : {}
  network_watcher_name = length(azurerm_network_watcher.this) > 0 ? azurerm_network_watcher.this[0].name : coalesce(var.network_watcher_name, "NetworkWatcher_${var.location}")
  network_watcher_rg   = length(azurerm_network_watcher.this) > 0 ? azurerm_network_watcher.this[0].resource_group_name : var.network_watcher_resource_group_name
}

resource "azurerm_network_watcher" "this" {
  count               = var.enable_flow_logs && var.create_network_watcher ? 1 : 0
  name                = coalesce(var.network_watcher_name, "NetworkWatcher_${var.location}")
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Flow logs are written by Network Watcher, which authenticates with account keys;
# access is limited to trusted Azure services.
#trivy:ignore:AVD-AZU-0010
resource "azurerm_storage_account" "flow_logs" {
  count                           = var.enable_flow_logs ? 1 : 0
  name                            = "stfl${substr(replace(var.name_prefix, "-", ""), 0, 13)}${var.unique_suffix}${var.name_suffix}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true
  tags                            = var.tags

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices", "Logging", "Metrics"]
  }
}

resource "azurerm_network_watcher_flow_log" "vnet" {
  for_each             = local.flow_log_vnets
  name                 = "${var.name_prefix}-fl-${each.key}-${var.name_suffix}"
  network_watcher_name = local.network_watcher_name
  resource_group_name  = local.network_watcher_rg
  location             = var.location
  target_resource_id   = each.value
  storage_account_id   = azurerm_storage_account.flow_logs[0].id
  enabled              = true
  version              = 2
  tags                 = var.tags

  retention_policy {
    enabled = true
    days    = var.flow_log_retention_days
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = var.log_analytics_workspace_guid
    workspace_region      = var.location
    workspace_resource_id = var.log_analytics_workspace_id
    interval_in_minutes   = 10
  }
}
