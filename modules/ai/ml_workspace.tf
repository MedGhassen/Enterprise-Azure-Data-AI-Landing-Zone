# ---------------------------------------------------------------------------
# Azure Machine Learning workspace (classic ML: training, pipelines, endpoints)
# ---------------------------------------------------------------------------
resource "azurerm_storage_account" "ml" {
  count                             = var.enable_ml_workspace ? 1 : 0
  name                              = "stml${substr(replace(var.name_prefix, "-", ""), 0, 13)}${var.unique_suffix}${var.name_suffix}"
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_tier                      = "Standard"
  account_replication_type          = "ZRS"
  account_kind                      = "StorageV2"
  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  shared_access_key_enabled         = false
  default_to_oauth_authentication   = true
  public_network_access_enabled     = false
  allow_nested_items_to_be_public   = false
  cross_tenant_replication_enabled  = false
  infrastructure_encryption_enabled = true
  tags                              = var.tags

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }
}

resource "azurerm_private_endpoint" "ml_storage" {
  for_each            = var.enable_ml_workspace ? toset(["blob", "file"]) : toset([])
  name                = "${var.name_prefix}-stml-${each.key}-pe-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "stml-${each.key}-psc"
    private_connection_resource_id = azurerm_storage_account.ml[0].id
    subresource_names              = [each.key]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.${each.key}.core.windows.net"]]
  }
}

resource "azurerm_machine_learning_workspace" "main" {
  count                         = var.enable_ml_workspace ? 1 : 0
  name                          = "${var.name_prefix}-mlw-${var.name_suffix}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  application_insights_id       = var.application_insights_id
  key_vault_id                  = var.key_vault_id
  storage_account_id            = azurerm_storage_account.ml[0].id
  storage_account_access_type   = "Identity"
  container_registry_id         = var.container_registry_id
  public_network_access_enabled = false
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }

  managed_network {
    isolation_mode = var.ml_isolation_mode
  }
}

resource "azurerm_private_endpoint" "ml" {
  count               = var.enable_ml_workspace ? 1 : 0
  name                = "${var.name_prefix}-mlw-pe-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "mlw-psc"
    private_connection_resource_id = azurerm_machine_learning_workspace.main[0].id
    subresource_names              = ["amlworkspace"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
      var.private_dns_zone_ids["privatelink.api.azureml.ms"],
      var.private_dns_zone_ids["privatelink.notebooks.azure.net"],
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "ml" {
  count                      = var.enable_ml_workspace ? 1 : 0
  name                       = "diag-to-law"
  target_resource_id         = azurerm_machine_learning_workspace.main[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}
