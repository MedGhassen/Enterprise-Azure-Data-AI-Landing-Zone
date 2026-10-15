output "resource_group_names" {
  description = "Workload resource group names keyed by role (network, shared, data, ai, serving)."
  value       = { for k, rg in azurerm_resource_group.this : k => rg.name }
}

output "unique_suffix" {
  description = "Suffix used for globally unique resource names."
  value       = local.unique_suffix
}

output "vnet_ids" {
  description = "Hub and spoke VNet IDs."
  value = {
    hub   = module.networking.hub_vnet_id
    spoke = module.networking.spoke_vnet_id
  }
}

output "subnet_ids" {
  description = "Spoke subnet IDs keyed by role."
  value       = module.networking.subnet_ids
}

output "private_dns_zone_ids" {
  description = "Private DNS zone IDs keyed by zone name."
  value       = module.networking.private_dns_zone_ids
}

output "firewall_private_ip" {
  description = "Azure Firewall private IP (null when disabled)."
  value       = module.networking.firewall_private_ip
}

output "firewall_policy_id" {
  description = "Firewall policy ID for workload rule collection groups (null when disabled)."
  value       = module.networking.firewall_policy_id
}

output "vpn_gateway_public_ip" {
  description = "P2S VPN Gateway public IP (null when disabled)."
  value       = module.networking.vpn_gateway_public_ip
}

output "dns_resolver_inbound_ip" {
  description = "DNS Private Resolver inbound IP (null when disabled)."
  value       = module.networking.dns_resolver_inbound_ip
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID."
  value       = module.monitoring.log_analytics_workspace_id
}

output "key_vault_uri" {
  description = "Key Vault URI."
  value       = module.security.key_vault_uri
}

output "storage_account_name" {
  description = "Data lake storage account name."
  value       = module.data_lake.storage_account_name
}

output "storage_dfs_endpoint" {
  description = "Data lake DFS endpoint."
  value       = module.data_lake.dfs_endpoint
}

output "data_factory_name" {
  description = "Data Factory name (null when disabled)."
  value       = try(module.data_factory[0].data_factory_name, null)
}

output "databricks_workspace_url" {
  description = "Databricks workspace URL (null when disabled)."
  value       = try(module.databricks[0].workspace_url, null)
}

output "databricks_access_connector_id" {
  description = "Access Connector ID for the Unity Catalog storage credential (null when disabled)."
  value       = try(module.databricks[0].access_connector_id, null)
}

output "synapse_connectivity_endpoints" {
  description = "Synapse endpoints (null when disabled)."
  value       = try(module.synapse[0].connectivity_endpoints, null)
}

output "sql_server_fqdn" {
  description = "Azure SQL server FQDN (null when disabled)."
  value       = try(module.databases[0].sql_server_fqdn, null)
}

output "cosmos_db_endpoint" {
  description = "Cosmos DB endpoint (null when disabled)."
  value       = try(module.databases[0].cosmos_db_endpoint, null)
}

output "event_hubs_namespace" {
  description = "Event Hubs namespace name (null when disabled)."
  value       = try(module.streaming[0].event_hubs_namespace_name, null)
}

output "foundry_endpoint" {
  description = "Microsoft Foundry (AI Services) endpoint (null when disabled)."
  value       = try(module.ai[0].foundry_endpoint, null)
}

output "foundry_project_ids" {
  description = "Foundry project IDs."
  value       = try(module.ai[0].foundry_project_ids, {})
}

output "search_endpoint" {
  description = "AI Search endpoint (null when disabled)."
  value       = try(module.ai[0].search_endpoint, null)
}

output "ml_workspace_id" {
  description = "Azure ML workspace ID (null when disabled)."
  value       = try(module.ai[0].ml_workspace_id, null)
}

output "acr_login_server" {
  description = "ACR login server."
  value       = module.serving.acr_login_server
}

output "aks_private_fqdn" {
  description = "AKS API server private FQDN (null when disabled)."
  value       = module.serving.aks_private_fqdn
}

output "aks_oidc_issuer_url" {
  description = "AKS OIDC issuer URL (null when disabled)."
  value       = module.serving.aks_oidc_issuer_url
}
