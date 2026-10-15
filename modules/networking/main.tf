locals {
  zonal_vpn_sku = endswith(var.vpn_gateway_sku, "AZ")
}

# ---------------------------------------------------------------------------
# Hub VNet: shared connectivity (Firewall, VPN Gateway, Bastion, DNS resolver)
# ---------------------------------------------------------------------------
resource "azurerm_virtual_network" "hub" {
  name                = "${var.name_prefix}-hub-vnet-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.hub_vnet_address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "firewall" {
  count                = var.enable_firewall ? 1 : 0
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnet_cidrs.firewall]
}

resource "azurerm_subnet" "bastion" {
  count                = var.enable_bastion ? 1 : 0
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnet_cidrs.bastion]
}

resource "azurerm_public_ip" "bastion" {
  count               = var.enable_bastion ? 1 : 0
  name                = "${var.name_prefix}-bastion-pip-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.availability_zones
  tags                = var.tags
}

resource "azurerm_bastion_host" "hub" {
  count               = var.enable_bastion ? 1 : 0
  name                = "${var.name_prefix}-bastion-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.bastion_sku
  tags                = var.tags

  ip_configuration {
    name                 = "config"
    subnet_id            = azurerm_subnet.bastion[0].id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }
}

# ---------------------------------------------------------------------------
# Spoke VNet: data, AI and serving workloads (private endpoints only)
# ---------------------------------------------------------------------------
resource "azurerm_virtual_network" "spoke" {
  name                = "${var.name_prefix}-spoke-vnet-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.spoke_vnet_address_space]
  tags                = var.tags
}

locals {
  # Subnets that host private endpoints or workloads, each with its own NSG.
  spoke_subnets = {
    data     = { name = "snet-data", cidr = var.subnet_cidrs.data }
    ai       = { name = "snet-ai", cidr = var.subnet_cidrs.ai }
    serving  = { name = "snet-serving", cidr = var.subnet_cidrs.serving }
    security = { name = "snet-security", cidr = var.subnet_cidrs.security }
  }
  databricks_subnets = {
    databricks_private = { name = "snet-databricks-private", cidr = var.subnet_cidrs.databricks_private }
    databricks_public  = { name = "snet-databricks-public", cidr = var.subnet_cidrs.databricks_public }
  }
}

resource "azurerm_network_security_group" "spoke" {
  for_each            = merge(local.spoke_subnets, local.databricks_subnets)
  name                = "${var.name_prefix}-nsg-${replace(each.key, "_", "")}-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "spoke" {
  for_each             = local.spoke_subnets
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [each.value.cidr]

  # Apply NSGs and UDRs to private endpoints in these subnets.
  private_endpoint_network_policies = "Enabled"
}

resource "azurerm_subnet" "databricks" {
  for_each             = local.databricks_subnets
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [each.value.cidr]

  delegation {
    name = "databricks"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "spoke" {
  for_each                  = azurerm_subnet.spoke
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.spoke[each.key].id
}

resource "azurerm_subnet_network_security_group_association" "databricks" {
  for_each                  = azurerm_subnet.databricks
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.spoke[each.key].id
}

# NAT Gateway for Databricks egress (secure cluster connectivity / no public IP).
resource "azurerm_public_ip" "nat" {
  count               = var.enable_nat_gateway ? 1 : 0
  name                = "${var.name_prefix}-ng-pip-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "databricks" {
  count               = var.enable_nat_gateway ? 1 : 0
  name                = "${var.name_prefix}-ng-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "databricks" {
  count                = var.enable_nat_gateway ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.databricks[0].id
  public_ip_address_id = azurerm_public_ip.nat[0].id
}

resource "azurerm_subnet_nat_gateway_association" "databricks" {
  for_each       = var.enable_nat_gateway ? azurerm_subnet.databricks : {}
  subnet_id      = each.value.id
  nat_gateway_id = azurerm_nat_gateway.databricks[0].id
}

# ---------------------------------------------------------------------------
# Hub <-> Spoke peering
# ---------------------------------------------------------------------------
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "hub-to-spoke"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.enable_vpn_gateway

  depends_on = [azurerm_virtual_network_gateway.vpn]
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "spoke-to-hub"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = var.enable_vpn_gateway

  depends_on = [azurerm_virtual_network_gateway.vpn]
}
