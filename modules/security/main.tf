data "azurerm_client_config" "current" {}

# Key Vault - Premium, soft-delete, purge protection, RBAC only, no public access
resource "azurerm_key_vault" "main" {
  name                          = substr("${var.name_prefix}-kv", 0, 24)
  location                      = var.primary_region
  resource_group_name           = var.resource_group_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = var.key_vault_sku
  soft_delete_retention_days    = 90
  purge_protection_enabled      = true
  enable_rbac_authorization     = true
  public_network_access_enabled = false
  tags                          = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_private_endpoint" "kv" {
  name                = "${var.name_prefix}-kv-pe-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_private_endpoint
  tags                = var.tags

  private_service_connection {
    name                           = "kv-psc"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_a_record" "kv" {
  count               = var.private_dns_zone_vault_name != "" && var.private_dns_zone_vault_rg != "" ? 1 : 0
  name                = split(".", azurerm_key_vault.main.name)[0]
  zone_name           = var.private_dns_zone_vault_name
  resource_group_name = var.private_dns_zone_vault_rg
  ttl                 = 300
  records             = [azurerm_private_endpoint.kv.private_service_connection[0].private_ip_address]
}

# Diagnostic settings for Key Vault
resource "azurerm_monitor_diagnostic_setting" "kv" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "kv-diag"
  target_resource_id         = azurerm_key_vault.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Microsoft Defender for Cloud
resource "azurerm_security_center_subscription_pricing" "plans" {
  for_each      = toset(var.defender_plans)
  tier          = "Standard"
  resource_type = each.key
}

resource "azurerm_security_center_contact" "main" {
  email = var.defender_contact_email
  phone = "+10000000000" # placeholder; set via variable if required

  alert_notifications = true
  alerts_to_admins    = true
}
