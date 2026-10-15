locals {
  ml_storage_name = substr(lower(replace("stml${var.name_prefix}${var.name_suffix}", "-", "")), 0, 24)
}

resource "azurerm_storage_account" "ml" {
  name                     = local.ml_storage_name
  resource_group_name      = var.resource_group_name
  location                 = var.primary_region
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = false
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

resource "azurerm_machine_learning_workspace" "main" {
  name                    = "${var.name_prefix}-mlw-${var.name_suffix}"
  location                = var.primary_region
  resource_group_name     = var.resource_group_name
  application_insights_id = var.application_insights_id
  key_vault_id            = var.key_vault_id
  storage_account_id      = azurerm_storage_account.ml.id
  tags                    = var.tags

  identity {
    type = "SystemAssigned"
  }

  public_network_access_enabled = false
}

# Private endpoint for ML workspace
resource "azurerm_private_endpoint" "ml" {
  name                = "${var.name_prefix}-ml-pe-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_ai
  tags                = var.tags

  private_service_connection {
    name                           = "ml-psc"
    private_connection_resource_id = azurerm_machine_learning_workspace.main.id
    subresource_names              = ["amlworkspace"]
    is_manual_connection           = false
  }
}

# Private DNS A record for AML (privatelink.api.azureml.ms - record name per Azure docs)
resource "azurerm_private_dns_a_record" "ml" {
  count               = var.dns_zone_aml_name != "" && var.dns_zone_aml_rg != "" ? 1 : 0
  name                = replace(azurerm_machine_learning_workspace.main.workspace_id, "-", "")
  zone_name           = var.dns_zone_aml_name
  resource_group_name = var.dns_zone_aml_rg
  ttl                 = 300
  records             = [azurerm_private_endpoint.ml.private_service_connection[0].private_ip_address]
}
