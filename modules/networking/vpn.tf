# ---------------------------------------------------------------------------
# VPN Gateway — Point-to-Site with Entra ID authentication
# ---------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

resource "azurerm_subnet" "gateway" {
  count                = var.enable_vpn_gateway ? 1 : 0
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnet_cidrs.gateway]
}

resource "azurerm_public_ip" "vpn_gateway" {
  count               = var.enable_vpn_gateway ? 1 : 0
  name                = "${var.name_prefix}-vpngw-pip-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = local.zonal_vpn_sku ? var.availability_zones : null
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "vpn" {
  count               = var.enable_vpn_gateway ? 1 : 0
  name                = "${var.name_prefix}-vpngw-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = var.vpn_gateway_sku
  active_active       = false
  bgp_enabled         = false
  tags                = var.tags

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway[0].id
  }

  vpn_client_configuration {
    address_space        = [var.vpn_client_address_pool]
    vpn_auth_types       = ["AAD"]
    vpn_client_protocols = ["OpenVPN"]

    aad_tenant   = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/"
    aad_audience = var.vpn_aad_audience
    aad_issuer   = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/"
  }
}

# ---------------------------------------------------------------------------
# Azure DNS Private Resolver
# P2S clients cannot reach 168.63.129.16, so an inbound endpoint in the hub
# resolves the private DNS zones. Its IP is set as the hub VNet DNS server,
# which the VPN Gateway pushes to clients.
# ---------------------------------------------------------------------------
resource "azurerm_subnet" "dns_resolver_inbound" {
  count                = var.enable_vpn_gateway ? 1 : 0
  name                 = "snet-dns-resolver-inbound"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnet_cidrs.dns_resolver_inbound]

  delegation {
    name = "dns-resolver"
    service_delegation {
      name    = "Microsoft.Network/dnsResolvers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_private_dns_resolver" "hub" {
  count               = var.enable_vpn_gateway ? 1 : 0
  name                = "${var.name_prefix}-dnspr-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  virtual_network_id  = azurerm_virtual_network.hub.id
  tags                = var.tags
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "hub" {
  count                   = var.enable_vpn_gateway ? 1 : 0
  name                    = "${var.name_prefix}-dnspr-in-${var.name_suffix}"
  private_dns_resolver_id = azurerm_private_dns_resolver.hub[0].id
  location                = var.location
  tags                    = var.tags

  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.dns_resolver_inbound[0].id
  }
}

resource "azurerm_virtual_network_dns_servers" "hub" {
  count              = var.enable_vpn_gateway ? 1 : 0
  virtual_network_id = azurerm_virtual_network.hub.id
  dns_servers        = [azurerm_private_dns_resolver_inbound_endpoint.hub[0].ip_configurations[0].private_ip_address]
}
