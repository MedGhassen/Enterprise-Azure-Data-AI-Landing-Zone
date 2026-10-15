# Azure AI Search - Standard SKU, semantic search, private endpoint
resource "azurerm_search_service" "main" {
  name                = "${var.name_prefix}-srch-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  sku                 = "standard"
  replica_count       = var.ai_search_replica_count
  partition_count     = var.ai_search_partition_count
  tags                = var.tags

  public_network_access_enabled = false
}

resource "azurerm_private_endpoint" "search" {
  name                = "${var.name_prefix}-srch-pe-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_ai
  tags                = var.tags

  private_service_connection {
    name                           = "srch-psc"
    private_connection_resource_id = azurerm_search_service.main.id
    subresource_names              = ["searchService"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_a_record" "search" {
  count               = var.dns_zone_search_name != "" && var.dns_zone_search_rg != "" ? 1 : 0
  name                = azurerm_search_service.main.name
  zone_name           = var.dns_zone_search_name
  resource_group_name = var.dns_zone_search_rg
  ttl                 = 300
  records             = [azurerm_private_endpoint.search.private_service_connection[0].private_ip_address]
}
