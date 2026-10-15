# ---------------------------------------------------------------------------
# Azure Firewall (hub) + policy + UDR forcing AKS egress through the firewall
# ---------------------------------------------------------------------------
resource "azurerm_public_ip" "firewall" {
  count               = var.enable_firewall ? 1 : 0
  name                = "${var.name_prefix}-fw-pip-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.availability_zones
  tags                = var.tags
}

resource "azurerm_firewall_policy" "hub" {
  count                    = var.enable_firewall ? 1 : 0
  name                     = "${var.name_prefix}-fwp-${var.name_suffix}"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  sku                      = var.firewall_sku
  threat_intelligence_mode = var.firewall_threat_intel_mode
  tags                     = var.tags
}

# Minimum egress required by AKS (https://learn.microsoft.com/azure/aks/outbound-rules-control-egress).
# Extend with your own rule collection groups for workload traffic.
resource "azurerm_firewall_policy_rule_collection_group" "platform" {
  count              = var.enable_firewall ? 1 : 0
  name               = "platform"
  firewall_policy_id = azurerm_firewall_policy.hub[0].id
  priority           = 200

  network_rule_collection {
    name     = "aks-network"
    priority = 200
    action   = "Allow"

    rule {
      name                  = "ntp"
      protocols             = ["UDP"]
      source_addresses      = [var.subnet_cidrs.serving]
      destination_addresses = ["*"]
      destination_ports     = ["123"]
    }

    rule {
      name                  = "azure-monitor"
      protocols             = ["TCP"]
      source_addresses      = [var.subnet_cidrs.serving]
      destination_addresses = ["AzureMonitor"]
      destination_ports     = ["443"]
    }
  }

  application_rule_collection {
    name     = "aks-application"
    priority = 300
    action   = "Allow"

    rule {
      name                  = "aks-fqdn-tag"
      source_addresses      = [var.subnet_cidrs.serving]
      destination_fqdn_tags = ["AzureKubernetesService"]
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        type = "Http"
        port = 80
      }
    }
  }
}

resource "azurerm_firewall" "hub" {
  count               = var.enable_firewall ? 1 : 0
  name                = "${var.name_prefix}-fw-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.firewall_sku
  firewall_policy_id  = azurerm_firewall_policy.hub[0].id
  zones               = var.availability_zones
  tags                = var.tags

  ip_configuration {
    name                 = "config"
    subnet_id            = azurerm_subnet.firewall[0].id
    public_ip_address_id = azurerm_public_ip.firewall[0].id
  }

  depends_on = [azurerm_firewall_policy_rule_collection_group.platform]
}

resource "azurerm_monitor_diagnostic_setting" "firewall" {
  count                          = var.enable_firewall ? 1 : 0
  name                           = "diag-to-law"
  target_resource_id             = azurerm_firewall.hub[0].id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category_group = "allLogs"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}

# Route table for the AKS (serving) subnet: default route via the firewall.
# BGP propagation stays enabled so P2S VPN client routes win over 0.0.0.0/0.
resource "azurerm_route_table" "serving" {
  count                         = var.enable_firewall ? 1 : 0
  name                          = "${var.name_prefix}-rt-serving-${var.name_suffix}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = true
  tags                          = var.tags

  route {
    name                   = "default-via-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hub[0].ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "serving" {
  count          = var.enable_firewall ? 1 : 0
  subnet_id      = azurerm_subnet.spoke["serving"].id
  route_table_id = azurerm_route_table.serving[0].id
}
