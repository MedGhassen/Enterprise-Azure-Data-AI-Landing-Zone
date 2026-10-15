# Multi-service Cognitive Services (vision, speech, language) - private endpoint only
resource "azurerm_cognitive_account" "multi" {
  name                  = "${var.name_prefix}-cog-${var.name_suffix}"
  location              = var.primary_region
  resource_group_name   = var.resource_group_name
  kind                  = "CognitiveServices"
  sku_name              = "S0"
  custom_subdomain_name = "${var.name_prefix}-cog-${var.name_suffix}"
  tags                  = var.tags

  public_network_access_enabled = false
}

resource "azurerm_private_endpoint" "cognitive" {
  name                = "${var.name_prefix}-cog-pe-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_ai
  tags                = var.tags

  private_service_connection {
    name                           = "cog-psc"
    private_connection_resource_id = azurerm_cognitive_account.multi.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_a_record" "cognitive" {
  count               = var.dns_zone_cognitive_name != "" && var.dns_zone_cognitive_rg != "" ? 1 : 0
  name                = azurerm_cognitive_account.multi.name
  zone_name           = var.dns_zone_cognitive_name
  resource_group_name = var.dns_zone_cognitive_rg
  ttl                 = 300
  records             = [azurerm_private_endpoint.cognitive.private_service_connection[0].private_ip_address]
}
