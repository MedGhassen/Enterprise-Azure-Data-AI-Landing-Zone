# Hub VNet
resource "azurerm_virtual_network" "hub" {
  name                = "${var.name_prefix}-hub-vnet-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  address_space       = [var.hub_vnet_address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.firewall_subnet_cidr]
}

resource "azurerm_subnet" "bastion" {
  count                = var.enable_bastion ? 1 : 0
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.bastion_subnet_cidr]
}

resource "azurerm_subnet" "gateway" {
  count                = var.enable_gateway ? 1 : 0
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.gateway_subnet_cidr]
}

# Hub public IP for Firewall
resource "azurerm_public_ip" "firewall" {
  name                = "${var.name_prefix}-fw-pip-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall" "hub" {
  name                = "${var.name_prefix}-fw-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.firewall_sku
  tags                = var.tags

  ip_configuration {
    name                 = "config"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

resource "azurerm_bastion_host" "hub" {
  count               = var.enable_bastion ? 1 : 0
  name                = "${var.name_prefix}-bastion-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                 = "config"
    subnet_id            = azurerm_subnet.bastion[0].id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }
}

resource "azurerm_public_ip" "bastion" {
  count               = var.enable_bastion ? 1 : 0
  name                = "${var.name_prefix}-bastion-pip-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Spoke VNet (single VNet with multiple subnets for data, AI, serving)
resource "azurerm_virtual_network" "spoke" {
  name                = "${var.name_prefix}-spoke-vnet-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  address_space       = [var.spoke_vnet_address_space]
  tags                = var.tags
}

# NSGs
resource "azurerm_network_security_group" "data" {
  name                = "${var.name_prefix}-nsg-data-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_group" "databricks_private" {
  name                = "${var.name_prefix}-nsg-dbprivate-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_group" "databricks_public" {
  name                = "${var.name_prefix}-nsg-dbpublic-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_group" "ai" {
  name                = "${var.name_prefix}-nsg-ai-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_group" "serving" {
  name                = "${var.name_prefix}-nsg-serving-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_group" "security" {
  name                = "${var.name_prefix}-nsg-security-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Subnets in spoke
resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.subnet_data_cidr]
}

resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.data.id
}

resource "azurerm_subnet" "databricks_private" {
  name                 = "snet-databricks-private"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.subnet_databricks_private_cidr]
  delegation {
    name = "databricks"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "databricks_private" {
  subnet_id                 = azurerm_subnet.databricks_private.id
  network_security_group_id = azurerm_network_security_group.databricks_private.id
}

resource "azurerm_subnet" "databricks_public" {
  name                 = "snet-databricks-public"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.subnet_databricks_public_cidr]
  delegation {
    name = "databricks"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "databricks_public" {
  subnet_id                 = azurerm_subnet.databricks_public.id
  network_security_group_id = azurerm_network_security_group.databricks_public.id
}

resource "azurerm_subnet" "ai" {
  name                 = "snet-ai"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.subnet_ai_cidr]
  service_endpoints    = ["Microsoft.CognitiveServices"]
}

resource "azurerm_subnet_network_security_group_association" "ai" {
  subnet_id                 = azurerm_subnet.ai.id
  network_security_group_id = azurerm_network_security_group.ai.id
}

resource "azurerm_subnet" "serving" {
  name                 = "snet-serving"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.subnet_serving_cidr]
}

resource "azurerm_subnet_network_security_group_association" "serving" {
  subnet_id                 = azurerm_subnet.serving.id
  network_security_group_id = azurerm_network_security_group.serving.id
}

resource "azurerm_subnet" "security" {
  name                 = "snet-security"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.subnet_security_cidr]
}

resource "azurerm_subnet_network_security_group_association" "security" {
  subnet_id                 = azurerm_subnet.security.id
  network_security_group_id = azurerm_network_security_group.security.id
}

# VNet peering: Hub <-> Spoke
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "hub-to-spoke"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.enable_gateway

  depends_on = [azurerm_virtual_network_gateway.vpn]
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "spoke-to-hub"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = var.enable_gateway

  depends_on = [azurerm_virtual_network_gateway.vpn]
}

# Private DNS zones (created in hub and linked to hub VNet)
resource "azurerm_private_dns_zone" "zones" {
  for_each            = toset(var.private_dns_zone_names)
  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  for_each              = azurerm_private_dns_zone.zones
  name                  = "hub-${replace(each.key, ".", "-")}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.hub.id
  registration_enabled  = false
  tags                  = var.tags
}

# Link private DNS zones to spoke so resources in spoke can resolve
resource "azurerm_private_dns_zone_virtual_network_link" "spoke" {
  for_each              = azurerm_private_dns_zone.zones
  name                  = "spoke-${replace(each.key, ".", "-")}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.spoke.id
  registration_enabled  = false
  tags                  = var.tags
}

# Network Watcher (required for flow logs)
resource "azurerm_network_watcher" "watcher" {
  count               = var.log_analytics_workspace_id != "" && var.flow_log_storage_account_id != "" ? 1 : 0
  name                = "${var.name_prefix}-nw-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# NSG flow logs (when LA and storage are provided)
resource "azurerm_network_watcher_flow_log" "data" {
  count                     = var.log_analytics_workspace_id != "" && var.flow_log_storage_account_id != "" ? 1 : 0
  name                      = "${var.name_prefix}-flow-data-${var.name_suffix}"
  network_watcher_name      = azurerm_network_watcher.watcher[0].name
  resource_group_name       = var.resource_group_name
  network_security_group_id = azurerm_network_security_group.data.id
  storage_account_id        = var.flow_log_storage_account_id
  enabled                   = true
  retention_policy {
    enabled = true
    days    = var.flow_log_retention_days
  }
  traffic_analytics {
    enabled               = true
    workspace_id          = var.log_analytics_workspace_id
    workspace_region      = var.primary_region
    workspace_resource_id = var.log_analytics_workspace_id
  }
}
