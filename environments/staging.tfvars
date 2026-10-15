# Staging: production-like topology at reduced scale.
environment     = "staging"
location        = "westeurope"
resource_prefix = "dataai"
instance_suffix = "001"
cost_center     = "CC002"
owner_email     = "dataai-staging@example.com"

# Networking
enable_firewall    = true
enable_bastion     = false
enable_vpn_gateway = false
enable_flow_logs   = true

# Monitoring & security
log_retention_days         = 90
key_vault_purge_protection = true
enable_resource_locks      = false

# Data
data_lake_replication   = "ZRS"
synapse_enable_sql_pool = false
cosmos_serverless       = false

# AI
ai_search_sku = "standard"

# Serving
aks_sku_tier          = "Standard"
aks_system_node_count = { min = 2, max = 3 }
aks_user_node_count   = { min = 1, max = 3 }
enable_purview        = false
