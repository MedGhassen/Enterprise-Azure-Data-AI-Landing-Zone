data "azurerm_client_config" "current" {}

# Key Vault: RBAC only, no public network access, purge protection.
resource "azurerm_key_vault" "main" {
  name                          = "kv-${substr(replace(var.name_prefix, "-", ""), 0, 12)}${var.unique_suffix}${var.name_suffix}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = var.key_vault_sku
  soft_delete_retention_days    = var.soft_delete_retention_days
  purge_protection_enabled      = var.purge_protection_enabled
  rbac_authorization_enabled    = true
  public_network_access_enabled = false
  tags                          = var.tags

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

resource "azurerm_private_endpoint" "kv" {
  name                = "${var.name_prefix}-kv-pe-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "kv-psc"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.vaultcore.azure.net"]]
  }
}

resource "azurerm_monitor_diagnostic_setting" "kv" {
  name                       = "diag-to-law"
  target_resource_id         = azurerm_key_vault.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "audit"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}

# ---------------------------------------------------------------------------
# Microsoft Defender for Cloud (subscription-scoped singletons).
# Enable in exactly ONE stack per subscription, otherwise stacks fight over them.
# ---------------------------------------------------------------------------
resource "azurerm_security_center_subscription_pricing" "plans" {
  for_each      = var.enable_defender ? toset(var.defender_plans) : toset([])
  tier          = "Standard"
  resource_type = each.key
}

resource "azurerm_security_center_contact" "main" {
  count               = var.enable_defender && var.defender_contact_email != null ? 1 : 0
  name                = "default"
  email               = var.defender_contact_email
  phone               = var.defender_contact_phone
  alert_notifications = true
  alerts_to_admins    = true
}
