# Synapse workspace: Entra-only auth, managed VNet, no public access.
resource "azurerm_synapse_workspace" "main" {
  name                                 = "${var.name_prefix}-syn-${var.unique_suffix}-${var.name_suffix}"
  resource_group_name                  = var.resource_group_name
  location                             = var.location
  storage_data_lake_gen2_filesystem_id = var.data_lake_filesystem_id
  managed_resource_group_name          = "${var.name_prefix}-syn-mrg-${var.name_suffix}"
  managed_virtual_network_enabled      = true
  data_exfiltration_protection_enabled = var.data_exfiltration_protection_enabled
  public_network_access_enabled        = false
  azuread_authentication_only          = true
  tags                                 = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_synapse_workspace_aad_admin" "main" {
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  login                = var.entra_admin_login
  object_id            = var.entra_admin_object_id
  tenant_id            = var.tenant_id
}

# Synapse managed identity can read/write the lake.
resource "azurerm_role_assignment" "lake" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.main.identity[0].principal_id
}

# Dedicated SQL pool is billed while running; disabled by default.
resource "azurerm_synapse_sql_pool" "main" {
  count                = var.enable_sql_pool ? 1 : 0
  name                 = "sqlpool"
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  sku_name             = var.sql_pool_sku
  create_mode          = "Default"
  storage_account_type = "GRS"
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  tags                 = var.tags
}

# Spark pool only costs while sessions run (auto-pause).
resource "azurerm_synapse_spark_pool" "main" {
  name                 = "sparkpool"
  synapse_workspace_id = azurerm_synapse_workspace.main.id
  node_size_family     = "MemoryOptimized"
  node_size            = var.spark_node_size
  spark_version        = var.spark_version
  tags                 = var.tags

  auto_scale {
    min_node_count = var.spark_min_nodes
    max_node_count = var.spark_max_nodes
  }

  auto_pause {
    delay_in_minutes = var.spark_auto_pause_minutes
  }
}

# Private endpoints: dedicated SQL, serverless SQL and dev (Studio API).
locals {
  synapse_endpoints = {
    Sql         = "privatelink.sql.azuresynapse.net"
    SqlOnDemand = "privatelink.sql.azuresynapse.net"
    Dev         = "privatelink.dev.azuresynapse.net"
  }
}

resource "azurerm_private_endpoint" "synapse" {
  for_each            = local.synapse_endpoints
  name                = "${var.name_prefix}-syn-${lower(each.key)}-pe-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "syn-${lower(each.key)}-psc"
    private_connection_resource_id = azurerm_synapse_workspace.main.id
    subresource_names              = [each.key]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids[each.value]]
  }
}

# Private Link Hub: serves Synapse Studio over private connectivity.
resource "azurerm_synapse_private_link_hub" "main" {
  name                = substr("${replace(var.name_prefix, "-", "")}synplh${var.name_suffix}", 0, 45)
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_private_endpoint" "web" {
  name                = "${var.name_prefix}-syn-web-pe-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "syn-web-psc"
    private_connection_resource_id = azurerm_synapse_private_link_hub.main.id
    subresource_names              = ["Web"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.azuresynapse.net"]]
  }
}

resource "azurerm_monitor_diagnostic_setting" "synapse" {
  name                       = "diag-to-law"
  target_resource_id         = azurerm_synapse_workspace.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
}
