# Azure Databricks: Premium, VNet-injected, secure cluster connectivity (no public IP),
# Private Link for front-end and back-end. With public access disabled the
# workspace (UI/API) is only reachable through the private endpoint (VPN/Bastion).
resource "azurerm_databricks_workspace" "main" {
  name                                  = "${var.name_prefix}-dbw-${var.name_suffix}"
  resource_group_name                   = var.resource_group_name
  location                              = var.location
  sku                                   = "premium"
  managed_resource_group_name           = "${var.name_prefix}-dbw-mrg-${var.name_suffix}"
  public_network_access_enabled         = var.public_network_access_enabled
  network_security_group_rules_required = var.public_network_access_enabled ? "AllRules" : "NoAzureDatabricksRules"
  tags                                  = var.tags

  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = var.virtual_network_id
    private_subnet_name                                  = var.private_subnet_name
    public_subnet_name                                   = var.public_subnet_name
    private_subnet_network_security_group_association_id = var.private_subnet_nsg_association_id
    public_subnet_network_security_group_association_id  = var.public_subnet_nsg_association_id
  }
}

# Front-end + back-end Private Link (databricks_ui_api).
resource "azurerm_private_endpoint" "ui_api" {
  name                = "${var.name_prefix}-dbw-pe-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "dbw-psc"
    private_connection_resource_id = azurerm_databricks_workspace.main.id
    subresource_names              = ["databricks_ui_api"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.azuredatabricks.net"]]
  }
}

# Web SSO callback endpoint. Only ONE is needed per region and private DNS zone;
# disable it when another workspace in the region already provides it.
resource "azurerm_private_endpoint" "browser_auth" {
  count               = var.create_browser_authentication_endpoint ? 1 : 0
  name                = "${var.name_prefix}-dbw-auth-pe-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "dbw-auth-psc"
    private_connection_resource_id = azurerm_databricks_workspace.main.id
    subresource_names              = ["browser_authentication"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.azuredatabricks.net"]]
  }

  depends_on = [azurerm_private_endpoint.ui_api]
}

# Access Connector: managed identity used by Unity Catalog to access the lake.
# Create the metastore / storage credential with the Databricks account console or
# the databricks provider, using this connector and abfss://unity@<lake>.dfs.core.windows.net/.
resource "azurerm_databricks_access_connector" "unity" {
  name                = "${var.name_prefix}-dbac-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "unity_lake" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.unity.identity[0].principal_id
}

resource "azurerm_monitor_diagnostic_setting" "dbw" {
  name                       = "diag-to-law"
  target_resource_id         = azurerm_databricks_workspace.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
}
