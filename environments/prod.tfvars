# Prod: zone-redundant, firewall egress, Bastion, Purview, resource locks.
environment     = "prod"
location        = "westeurope"
resource_prefix = "dataai"
instance_suffix = "001"
cost_center     = "CC003"
owner_email     = "dataai-prod@example.com"

# Networking
enable_firewall            = true
firewall_threat_intel_mode = "Deny"
enable_bastion             = true
enable_vpn_gateway         = false
enable_flow_logs           = true

# Monitoring & security
log_retention_days         = 365
key_vault_purge_protection = true
enable_resource_locks      = true
# Defender plans are subscription-wide: enable here only if no other stack manages them.
enable_defender = false

# Data
data_lake_replication   = "GZRS"
synapse_enable_sql_pool = true
cosmos_serverless       = false

# AI
ai_search_sku           = "standard"
ai_search_replica_count = 2

# Serving
aks_sku_tier          = "Standard"
aks_system_node_count = { min = 3, max = 5 }
aks_user_node_count   = { min = 2, max = 10 }
enable_purview        = true
