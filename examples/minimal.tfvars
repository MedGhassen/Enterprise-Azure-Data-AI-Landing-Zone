# Minimal: the cheapest useful footprint - private hub/spoke, Key Vault, monitoring,
# data lake, Data Factory and a Foundry project with AI Search. No firewall, AKS,
# Databricks, Synapse, SQL, Cosmos DB or Event Hubs.
#
#   terraform plan -var-file=examples/minimal.tfvars
#
# Reach private endpoints from a VNet-connected machine, or set enable_vpn_gateway = true.
environment     = "dev"
location        = "swedencentral"
resource_prefix = "dataai"
cost_center     = "demo"
owner_email     = "you@example.com"

enable_firewall    = false
enable_vpn_gateway = false

log_retention_days         = 30
log_daily_quota_gb         = 1
key_vault_purge_protection = false
data_lake_replication      = "LRS"

enable_data_factory = true
enable_databricks   = false
enable_synapse      = false
enable_sql_database = false
enable_cosmos_db    = false
enable_event_hubs   = false

enable_foundry      = true
enable_ai_search    = true
ai_search_sku       = "basic"
enable_ml_workspace = false

enable_aks     = false
enable_purview = false
