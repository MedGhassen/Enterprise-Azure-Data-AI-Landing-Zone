# Networking module

Hub-spoke network: hub VNet (Azure Firewall + policy, optional P2S VPN Gateway with Entra ID auth and DNS Private Resolver, optional Bastion), spoke VNet with per-role subnets and NSGs, Databricks-delegated subnets with a NAT Gateway, hub-spoke peering, a UDR sending AKS egress through the firewall, private DNS zones linked to both VNets, and optional VNet flow logs with Traffic Analytics.

Used by the root landing zone stack; see the [main README](../../README.md) for the architecture.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.9.0 |
| azurerm | >= 4.40, < 5.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_bastion_host.hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host) | resource |
| [azurerm_firewall.hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) | resource |
| [azurerm_firewall_policy.hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy) | resource |
| [azurerm_firewall_policy_rule_collection_group.platform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy_rule_collection_group) | resource |
| [azurerm_monitor_diagnostic_setting.firewall](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_nat_gateway.databricks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |
| [azurerm_nat_gateway_public_ip_association.databricks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) | resource |
| [azurerm_network_security_group.spoke](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_watcher.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher) | resource |
| [azurerm_network_watcher_flow_log.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher_flow_log) | resource |
| [azurerm_private_dns_resolver.hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver) | resource |
| [azurerm_private_dns_resolver_inbound_endpoint.hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_inbound_endpoint) | resource |
| [azurerm_private_dns_zone.zones](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.spoke](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_public_ip.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.firewall](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.nat](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.vpn_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_route_table.serving](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_storage_account.flow_logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_subnet.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.databricks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.dns_resolver_inbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.firewall](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.spoke](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_nat_gateway_association.databricks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |
| [azurerm_subnet_network_security_group_association.databricks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.spoke](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.serving](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network.hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network.spoke](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_dns_servers.hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_dns_servers) | resource |
| [azurerm_virtual_network_gateway.vpn](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway) | resource |
| [azurerm_virtual_network_peering.hub_to_spoke](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.spoke_to_hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| location | Azure region. | `string` | n/a | yes |
| log\_analytics\_workspace\_guid | Log Analytics workspace (customer) ID, required by Traffic Analytics. | `string` | n/a | yes |
| log\_analytics\_workspace\_id | Log Analytics workspace resource ID (diagnostics, Traffic Analytics). | `string` | n/a | yes |
| name\_prefix | Prefix for resource names, e.g. `dataai-dev-weu`. | `string` | n/a | yes |
| name\_suffix | Instance suffix for resource names, e.g. `001`. | `string` | n/a | yes |
| resource\_group\_name | Resource group for networking resources. | `string` | n/a | yes |
| unique\_suffix | Short random suffix used for globally unique names (flow log storage account). | `string` | n/a | yes |
| availability\_zones | Availability zones for zonal resources (Firewall, public IPs). Use [] in regions without zones. | `list(string)` | ```[ "1", "2", "3" ]``` | no |
| bastion\_sku | Azure Bastion SKU (Basic, Standard, Premium). | `string` | `"Basic"` | no |
| create\_network\_watcher | Create the Network Watcher (only if automatic creation is disabled in the subscription). | `bool` | `false` | no |
| enable\_bastion | Deploy Azure Bastion in the hub. | `bool` | `false` | no |
| enable\_firewall | Deploy Azure Firewall + policy in the hub and route the serving (AKS) subnet through it. | `bool` | `true` | no |
| enable\_flow\_logs | Enable VNet flow logs with Traffic Analytics for hub and spoke. | `bool` | `false` | no |
| enable\_nat\_gateway | Attach a NAT Gateway to the Databricks subnets for outbound connectivity. | `bool` | `true` | no |
| enable\_vpn\_gateway | Deploy a P2S VPN Gateway (Entra ID auth) and a DNS Private Resolver in the hub. | `bool` | `false` | no |
| firewall\_sku | Azure Firewall tier (Standard or Premium). | `string` | `"Standard"` | no |
| firewall\_threat\_intel\_mode | Threat intelligence mode for the firewall policy (Off, Alert, Deny). | `string` | `"Alert"` | no |
| flow\_log\_retention\_days | Flow log retention in days. | `number` | `90` | no |
| hub\_vnet\_address\_space | Hub VNet address space. | `string` | `"10.0.0.0/16"` | no |
| network\_watcher\_name | Network Watcher name. Azure's auto-created watcher is NetworkWatcher\_<region>. | `string` | `null` | no |
| network\_watcher\_resource\_group\_name | Resource group of the Network Watcher. | `string` | `"NetworkWatcherRG"` | no |
| private\_dns\_zone\_names | Private DNS zones to create and link to hub and spoke. | `list(string)` | ```[ "privatelink.blob.core.windows.net", "privatelink.dfs.core.windows.net", "privatelink.file.core.windows.net", "privatelink.vaultcore.azure.net", "privatelink.sql.azuresynapse.net", "privatelink.dev.azuresynapse.net", "privatelink.azuresynapse.net", "privatelink.database.windows.net", "privatelink.documents.azure.com", "privatelink.servicebus.windows.net", "privatelink.datafactory.azure.net", "privatelink.adf.azure.com", "privatelink.azuredatabricks.net", "privatelink.api.azureml.ms", "privatelink.notebooks.azure.net", "privatelink.cognitiveservices.azure.com", "privatelink.openai.azure.com", "privatelink.services.ai.azure.com", "privatelink.search.windows.net", "privatelink.azurecr.io", "privatelink.purview.azure.com", "privatelink.purviewstudio.azure.com" ]``` | no |
| spoke\_vnet\_address\_space | Spoke VNet address space. | `string` | `"10.1.0.0/16"` | no |
| subnet\_cidrs | Subnet CIDRs. Hub: firewall (min /26), bastion (min /26), gateway (min /27), dns\_resolver\_inbound (min /28). Spoke: the rest. | ```object({ firewall = optional(string, "10.0.1.0/26") bastion = optional(string, "10.0.2.0/26") gateway = optional(string, "10.0.3.0/27") dns_resolver_inbound = optional(string, "10.0.4.0/28") data = optional(string, "10.1.1.0/24") databricks_private = optional(string, "10.1.2.0/24") databricks_public = optional(string, "10.1.3.0/24") ai = optional(string, "10.1.4.0/24") serving = optional(string, "10.1.5.0/24") security = optional(string, "10.1.6.0/24") })``` | `{}` | no |
| tags | Tags applied to all resources. | `map(string)` | `{}` | no |
| vpn\_aad\_audience | Application ID of the Azure VPN client. Default is the Microsoft-registered Azure VPN Client app (no admin consent needed); the legacy value is 41b23e61-6c1e-4545-b367-cd054e0ed4b4. | `string` | `"c632b3df-fb67-4d84-bdcf-b95ad541b5c8"` | no |
| vpn\_client\_address\_pool | Address pool for P2S VPN clients (must not overlap hub/spoke). | `string` | `"172.16.0.0/24"` | no |
| vpn\_gateway\_sku | VPN Gateway SKU. Zone-redundant (AZ) SKUs are recommended; non-AZ SKUs are being retired. | `string` | `"VpnGw1AZ"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| databricks\_nsg\_association\_ids | NSG association IDs for the Databricks subnets (required by VNet injection). |
| dns\_resolver\_inbound\_ip | DNS Private Resolver inbound endpoint IP (null when disabled). |
| egress\_ready | Opaque value that is known once egress routing for the serving subnet is in place. Use as a dependency for AKS. |
| firewall\_policy\_id | Firewall policy ID, for adding workload rule collection groups (null when disabled). |
| firewall\_private\_ip | Azure Firewall private IP (null when disabled). |
| hub\_vnet\_id | Hub VNet ID. |
| private\_dns\_zone\_ids | Private DNS zone IDs keyed by zone name. |
| serving\_route\_table\_id | Route table on the serving subnet (null when the firewall is disabled). |
| spoke\_vnet\_id | Spoke VNet ID. |
| subnet\_ids | Spoke subnet IDs keyed by role (data, ai, serving, security, databricks\_private, databricks\_public). |
| subnet\_names | Spoke subnet names keyed by role. |
| vpn\_gateway\_id | VPN Gateway ID (null when disabled). |
| vpn\_gateway\_public\_ip | VPN Gateway public IP (null when disabled). |
<!-- END_TF_DOCS -->
