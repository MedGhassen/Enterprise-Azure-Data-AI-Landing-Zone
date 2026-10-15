output "resource_group_name" {
  description = "Resource group name"
  value       = var.resource_group_name
}

output "hub_vnet_id" {
  description = "Hub VNet ID"
  value       = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  description = "Hub VNet name"
  value       = azurerm_virtual_network.hub.name
}

output "spoke_vnet_id" {
  description = "Spoke VNet ID"
  value       = azurerm_virtual_network.spoke.id
}

output "spoke_vnet_name" {
  description = "Spoke VNet name"
  value       = azurerm_virtual_network.spoke.name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value = {
    snet_data               = azurerm_subnet.data.id
    snet_databricks_private = azurerm_subnet.databricks_private.id
    snet_databricks_public  = azurerm_subnet.databricks_public.id
    snet_ai                 = azurerm_subnet.ai.id
    snet_serving            = azurerm_subnet.serving.id
    snet_security           = azurerm_subnet.security.id
  }
}

output "firewall_private_ip" {
  description = "Azure Firewall private IP (from subnet)"
  value       = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}

output "private_dns_zone_ids" {
  description = "Map of private DNS zone name to ID"
  value       = { for k, v in azurerm_private_dns_zone.zones : k => v.id }
}

output "private_dns_zone_names" {
  description = "List of private DNS zone names"
  value       = [for z in azurerm_private_dns_zone.zones : z.name]
}

output "nsg_association_ids" {
  description = "Map of NSG association resource IDs"
  value = {
    databricks_private = azurerm_subnet_network_security_group_association.databricks_private.id
    databricks_public  = azurerm_subnet_network_security_group_association.databricks_public.id
  }
}

output "nsg_ids" {
  description = "Map of NSG names to IDs"
  value = {
    data               = azurerm_network_security_group.data.id
    databricks_private = azurerm_network_security_group.databricks_private.id
    databricks_public  = azurerm_network_security_group.databricks_public.id
    ai                 = azurerm_network_security_group.ai.id
    serving            = azurerm_network_security_group.serving.id
    security           = azurerm_network_security_group.security.id
  }
}

output "vpn_gateway_id" {
  description = "VPN Gateway ID (null when gateway is disabled)"
  value       = var.enable_gateway ? azurerm_virtual_network_gateway.vpn[0].id : null
}

output "vpn_gateway_public_ip" {
  description = "VPN Gateway public IP address"
  value       = var.enable_gateway ? azurerm_public_ip.vpn_gateway[0].ip_address : null
}

output "dns_resolver_inbound_ip" {
  description = "DNS Private Resolver inbound endpoint IP (used as DNS server for VPN clients)"
  value       = var.enable_gateway ? azurerm_private_dns_resolver_inbound_endpoint.hub[0].ip_configurations[0].private_ip_address : null
}
