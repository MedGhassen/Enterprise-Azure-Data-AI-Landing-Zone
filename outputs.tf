# Root-level outputs re-exporting from child modules

output "resource_group_name" {
  description = "Main resource group name"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "Main resource group ID"
  value       = azurerm_resource_group.main.id
}

output "vnet_ids" {
  description = "VNet IDs (hub and spoke)"
  value = {
    hub   = module.networking.hub_vnet_id
    spoke = module.networking.spoke_vnet_id
  }
}

output "subnet_ids" {
  description = "Subnet IDs by name"
  value       = module.networking.subnet_ids
}

output "storage_account_id" {
  description = "ADLS Gen2 storage account ID"
  value       = module.data_lake.storage_account_id
}

output "storage_dfs_endpoint" {
  description = "ADLS Gen2 DFS endpoint"
  value       = module.data_lake.storage_dfs_endpoint
}

output "databricks_workspace_url" {
  description = "Databricks workspace URL"
  value       = module.databricks.workspace_url
}

output "synapse_sql_endpoint" {
  description = "Synapse dedicated SQL pool endpoint"
  value       = module.synapse.sql_endpoint
}

output "synapse_spark_endpoint" {
  description = "Synapse Spark pool endpoint"
  value       = module.synapse.spark_endpoint
}

output "synapse_dev_endpoint" {
  description = "Synapse dev endpoint"
  value       = module.synapse.dev_endpoint
}

output "ml_workspace_id" {
  description = "Azure ML workspace ID"
  value       = module.ai_ml.ml_workspace_id
}

output "ai_foundry_hub_id" {
  description = "Azure AI Foundry Hub ID"
  value       = module.ai_ml.ai_foundry_hub_id
}

output "openai_endpoint" {
  description = "Azure OpenAI endpoint"
  value       = module.ai_ml.openai_endpoint
}

output "aks_fqdn" {
  description = "AKS private FQDN"
  value       = module.serving.aks_fqdn
}

output "aks_kubeconfig" {
  description = "AKS kubeconfig (use with private access)"
  value       = module.serving.aks_kubeconfig
  sensitive   = true
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = module.security.key_vault_uri
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = module.monitoring.log_analytics_workspace_id
}

output "data_factory_id" {
  description = "Azure Data Factory ID"
  value       = module.data_factory.data_factory_id
}

output "event_hubs_namespace" {
  description = "Event Hubs namespace name"
  value       = module.streaming.event_hubs_namespace
}

output "cosmos_db_endpoint" {
  description = "Cosmos DB endpoint"
  value       = module.databases.cosmos_db_endpoint
}

output "sql_server_fqdn" {
  description = "Azure SQL server FQDN"
  value       = module.databases.sql_server_fqdn
}
