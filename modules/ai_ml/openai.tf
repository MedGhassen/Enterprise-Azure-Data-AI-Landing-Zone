# Azure OpenAI Service - kind OpenAI, SKU S0, custom subdomain, network ACLs, private endpoint
resource "azurerm_cognitive_account" "openai" {
  name                  = "${var.name_prefix}-openai-${var.name_suffix}"
  location              = var.primary_region
  resource_group_name   = var.resource_group_name
  kind                  = "OpenAI"
  sku_name              = "S0"
  custom_subdomain_name = "${var.name_prefix}-openai-${var.name_suffix}"
  tags                  = var.tags

  public_network_access_enabled = false

  network_acls {
    default_action = "Deny"
    dynamic "virtual_network_rules" {
      for_each = var.vnet_subnet_id_openai != "" ? [1] : []
      content {
        subnet_id                            = var.vnet_subnet_id_openai
        ignore_missing_vnet_service_endpoint = false
      }
    }
  }
}

resource "azurerm_private_endpoint" "openai" {
  name                = "${var.name_prefix}-openai-pe-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_ai
  tags                = var.tags

  private_service_connection {
    name                           = "openai-psc"
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_a_record" "openai" {
  count               = var.dns_zone_openai_name != "" && var.dns_zone_openai_rg != "" ? 1 : 0
  name                = azurerm_cognitive_account.openai.custom_subdomain_name
  zone_name           = var.dns_zone_openai_name
  resource_group_name = var.dns_zone_openai_rg
  ttl                 = 300
  records             = [azurerm_private_endpoint.openai.private_service_connection[0].private_ip_address]
}

# OpenAI deployments (gpt-4, etc.)
resource "azurerm_cognitive_deployment" "openai" {
  for_each             = { for d in var.openai_deployments : d.name => d }
  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.openai.id
  model {
    format  = "OpenAI"
    name    = each.value.model
    version = each.value.version
  }
  scale {
    type     = "GlobalStandard"
    capacity = each.value.capacity
  }
}
