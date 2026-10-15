output "hub_vnet_id" {
  description = "Hub VNet ID."
  value       = azurerm_virtual_network.hub.id
}

output "spoke_vnet_id" {
  description = "Spoke VNet ID."
  value       = azurerm_virtual_network.spoke.id
}

output "subnet_ids" {
  description = "Spoke subnet IDs keyed by role (data, ai, serving, security, databricks_private, databricks_public)."
  value = merge(
    { for k, s in azurerm_subnet.spoke : k => s.id },
    { for k, s in azurerm_subnet.databricks : k => s.id },
  )
}

output "subnet_names" {
  description = "Spoke subnet names keyed by role."
  value = merge(
    { for k, s in azurerm_subnet.spoke : k => s.name },
    { for k, s in azurerm_subnet.databricks : k => s.name },
  )
}

output "databricks_nsg_association_ids" {
  description = "NSG association IDs for the Databricks subnets (required by VNet injection)."
  value       = { for k, a in azurerm_subnet_network_security_group_association.databricks : k => a.id }
}

output "private_dns_zone_ids" {
  description = "Private DNS zone IDs keyed by zone name."
  value       = { for k, z in azurerm_private_dns_zone.zones : k => z.id }
}

output "firewall_private_ip" {
  description = "Azure Firewall private IP (null when disabled)."
  value       = try(azurerm_firewall.hub[0].ip_configuration[0].private_ip_address, null)
}

output "firewall_policy_id" {
  description = "Firewall policy ID, for adding workload rule collection groups (null when disabled)."
  value       = try(azurerm_firewall_policy.hub[0].id, null)
}

output "serving_route_table_id" {
  description = "Route table on the serving subnet (null when the firewall is disabled)."
  value       = try(azurerm_route_table.serving[0].id, null)
}

output "egress_ready" {
  description = "Opaque value that is known once egress routing for the serving subnet is in place. Use as a dependency for AKS."
  value       = var.enable_firewall ? azurerm_subnet_route_table_association.serving[0].id : azurerm_subnet.spoke["serving"].id
}

output "vpn_gateway_id" {
  description = "VPN Gateway ID (null when disabled)."
  value       = try(azurerm_virtual_network_gateway.vpn[0].id, null)
}

output "vpn_gateway_public_ip" {
  description = "VPN Gateway public IP (null when disabled)."
  value       = try(azurerm_public_ip.vpn_gateway[0].ip_address, null)
}

output "dns_resolver_inbound_ip" {
  description = "DNS Private Resolver inbound endpoint IP (null when disabled)."
  value       = try(azurerm_private_dns_resolver_inbound_endpoint.hub[0].ip_configurations[0].private_ip_address, null)
}
