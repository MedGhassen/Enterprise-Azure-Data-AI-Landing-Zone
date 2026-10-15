# Full: every capability enabled (production-like). Expect significant cost.
#
#   terraform plan -var-file=examples/full.tfvars
environment     = "prod"
location        = "westeurope"
resource_prefix = "dataai"
cost_center     = "demo"
owner_email     = "you@example.com"

enable_firewall    = true
firewall_sku       = "Premium"
enable_bastion     = true
enable_vpn_gateway = true
enable_flow_logs   = true

log_retention_days    = 365
enable_resource_locks = true

data_lake_replication   = "GZRS"
enable_data_factory     = true
enable_databricks       = true
enable_synapse          = true
synapse_enable_sql_pool = true
enable_sql_database     = true
enable_cosmos_db        = true
enable_event_hubs       = true
enable_stream_analytics = true

enable_foundry          = true
enable_ai_search        = true
ai_search_replica_count = 3
enable_ml_workspace     = true

enable_aks     = true
enable_purview = true

adf_git = {
  repo_url = "https://github.com/your-org/your-adf-repo"
}
