# Dev: cost-optimised, developer access through P2S VPN, no firewall.
environment     = "dev"
location        = "westeurope"
resource_prefix = "dataai"
instance_suffix = "001"
cost_center     = "CC001"
owner_email     = "dataai-dev@example.com"

# Networking
enable_firewall    = false
enable_bastion     = false
enable_vpn_gateway = true
enable_flow_logs   = false

# Monitoring & security
log_retention_days         = 30
log_daily_quota_gb         = 5
key_vault_purge_protection = false
enable_resource_locks      = false

# Data
data_lake_replication   = "LRS"
synapse_enable_sql_pool = false
cosmos_serverless       = true

# AI
ai_search_sku = "basic"

# Serving
aks_sku_tier          = "Free"
aks_system_node_count = { min = 1, max = 2 }
aks_user_node_count   = { min = 0, max = 2 }
enable_purview        = false
