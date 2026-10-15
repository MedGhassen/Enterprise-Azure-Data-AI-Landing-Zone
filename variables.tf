# ---------------------------------------------------------------------------
# General
# ---------------------------------------------------------------------------
variable "subscription_id" {
  description = "Target subscription ID. null uses ARM_SUBSCRIPTION_ID / the Azure CLI context."
  type        = string
  default     = null
}

variable "project_name" {
  description = "Project name used in tags."
  type        = string
  default     = "dataai"
}

variable "environment" {
  description = "Environment: dev, staging or prod."
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "westeurope"
  validation {
    condition     = contains(keys(local.regions), lower(var.location))
    error_message = "location is not in the supported region list (see locals.tf); add it there with a short code."
  }
}

variable "resource_prefix" {
  description = "Short prefix for resource names (2-10 lowercase letters/digits)."
  type        = string
  default     = "dataai"
  validation {
    condition     = can(regex("^[a-z][a-z0-9]{1,9}$", var.resource_prefix))
    error_message = "resource_prefix must be 2-10 lowercase letters/digits, starting with a letter."
  }
}

variable "instance_suffix" {
  description = "Instance number appended to names."
  type        = string
  default     = "001"
  validation {
    condition     = can(regex("^[0-9]{3}$", var.instance_suffix))
    error_message = "instance_suffix must be three digits, e.g. 001."
  }
}

variable "unique_suffix" {
  description = "4-character suffix for globally unique names (storage, Key Vault, ACR, ...). null generates a random one, kept in state."
  type        = string
  default     = null
  validation {
    condition     = var.unique_suffix == null || can(regex("^[a-z0-9]{4}$", var.unique_suffix))
    error_message = "unique_suffix must be exactly 4 lowercase letters/digits."
  }
}

variable "cost_center" {
  description = "Cost center tag."
  type        = string
}

variable "owner_email" {
  description = "Owner email: used for tags, alert notifications and the Defender security contact."
  type        = string
  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.owner_email))
    error_message = "owner_email must be a valid email address."
  }
}

variable "additional_tags" {
  description = "Extra tags merged into the common tags."
  type        = map(string)
  default     = {}
}

variable "availability_zones" {
  description = "Availability zones for zonal resources (Firewall, public IPs, AKS). Use [] in regions without zones."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "enable_resource_locks" {
  description = "Put CanNotDelete locks on the workload resource groups (recommended for prod)."
  type        = bool
  default     = false
}

variable "entra_admin_object_id" {
  description = "Entra user/group object ID administering Azure SQL and Synapse (Entra-only auth). null = the deploying identity."
  type        = string
  default     = null
}

variable "entra_admin_login" {
  description = "Display name of the Entra SQL administrator (when entra_admin_object_id is set)."
  type        = string
  default     = "sql-entra-admins"
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------
variable "hub_vnet_address_space" {
  description = "Hub VNet address space."
  type        = string
  default     = "10.0.0.0/16"
}

variable "spoke_vnet_address_space" {
  description = "Spoke VNet address space."
  type        = string
  default     = "10.1.0.0/16"
}

variable "subnet_cidrs" {
  description = "Subnet CIDR overrides (see modules/networking for keys and defaults)."
  type        = map(string)
  default     = {}
}

variable "enable_firewall" {
  description = "Deploy Azure Firewall and route AKS egress through it."
  type        = bool
  default     = true
}

variable "firewall_sku" {
  description = "Azure Firewall tier (Standard or Premium)."
  type        = string
  default     = "Standard"
}

variable "firewall_threat_intel_mode" {
  description = "Firewall threat intelligence mode (Off, Alert, Deny)."
  type        = string
  default     = "Alert"
}

variable "enable_bastion" {
  description = "Deploy Azure Bastion in the hub."
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  description = "Deploy the P2S VPN Gateway (Entra ID auth) and DNS Private Resolver."
  type        = bool
  default     = false
}

variable "vpn_gateway_sku" {
  description = "VPN Gateway SKU (zone-redundant AZ SKUs recommended)."
  type        = string
  default     = "VpnGw1AZ"
}

variable "vpn_client_address_pool" {
  description = "Address pool for P2S VPN clients (must not overlap hub/spoke)."
  type        = string
  default     = "172.16.0.0/24"
}

variable "enable_flow_logs" {
  description = "Enable VNet flow logs + Traffic Analytics."
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# Monitoring & security
# ---------------------------------------------------------------------------
variable "log_retention_days" {
  description = "Log Analytics retention in days."
  type        = number
  default     = 90
}

variable "log_daily_quota_gb" {
  description = "Log Analytics daily cap in GB (-1 = unlimited)."
  type        = number
  default     = -1
}

variable "alert_webhook_url" {
  description = "Optional webhook for the alert action group."
  type        = string
  default     = null
  sensitive   = true
}

variable "key_vault_purge_protection" {
  description = "Enable Key Vault purge protection (cannot be disabled later)."
  type        = bool
  default     = true
}

variable "enable_defender" {
  description = "Manage Defender for Cloud plans for the subscription. Enable in only ONE stack per subscription."
  type        = bool
  default     = false
}

variable "defender_plans" {
  description = "Defender for Cloud plans to enable."
  type        = list(string)
  default     = ["StorageAccounts", "SqlServers", "KeyVaults", "Containers", "Arm", "CosmosDbs", "AI"]
}

# ---------------------------------------------------------------------------
# Data platform
# ---------------------------------------------------------------------------
variable "data_lake_replication" {
  description = "Data lake replication (LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS)."
  type        = string
  default     = "ZRS"
}

variable "enable_data_factory" {
  description = "Deploy Azure Data Factory."
  type        = bool
  default     = true
}

variable "adf_git" {
  description = "Optional Data Factory Git integration. repo_url: https://github.com/<owner>/<repo> or https://dev.azure.com/<org>/<project>/_git/<repo>."
  type = object({
    type        = optional(string, "GitHub")
    repo_url    = string
    branch      = optional(string, "main")
    root_folder = optional(string, "/")
  })
  default = null
}

variable "enable_databricks" {
  description = "Deploy Azure Databricks (VNet-injected, Private Link)."
  type        = bool
  default     = true
}

variable "databricks_public_network_access" {
  description = "Allow internet access to the Databricks UI/API (false = private only)."
  type        = bool
  default     = false
}

variable "enable_synapse" {
  description = "Deploy Azure Synapse Analytics."
  type        = bool
  default     = true
}

variable "synapse_enable_sql_pool" {
  description = "Create a Synapse dedicated SQL pool (billed while running)."
  type        = bool
  default     = false
}

variable "synapse_sql_pool_sku" {
  description = "Synapse dedicated SQL pool SKU."
  type        = string
  default     = "DW100c"
}

variable "enable_sql_database" {
  description = "Deploy Azure SQL Database."
  type        = bool
  default     = true
}

variable "sql_database_sku" {
  description = "Azure SQL database SKU."
  type        = string
  default     = "GP_S_Gen5_1"
}

variable "enable_cosmos_db" {
  description = "Deploy Cosmos DB (NoSQL)."
  type        = bool
  default     = true
}

variable "cosmos_serverless" {
  description = "Use Cosmos DB serverless capacity mode."
  type        = bool
  default     = false
}

variable "cosmos_failover_locations" {
  description = "Cosmos DB failover regions."
  type        = list(string)
  default     = []
}

variable "enable_event_hubs" {
  description = "Deploy Event Hubs."
  type        = bool
  default     = true
}

variable "event_hubs" {
  description = "Event hubs to create."
  type = list(object({
    name              = string
    partition_count   = optional(number, 4)
    message_retention = optional(number, 7)
  }))
  default = [{ name = "ingest" }]
}

variable "enable_stream_analytics" {
  description = "Deploy a Stream Analytics job (requires event hubs)."
  type        = bool
  default     = false
}

variable "stream_analytics_query" {
  description = "Stream Analytics transformation query."
  type        = string
  default     = "SELECT * INTO [output] FROM [input]"
}

# ---------------------------------------------------------------------------
# AI
# ---------------------------------------------------------------------------
variable "enable_foundry" {
  description = "Deploy Microsoft Foundry (AI Services account, projects, model deployments)."
  type        = bool
  default     = true
}

variable "foundry_projects" {
  description = "Foundry projects."
  type = list(object({
    name         = string
    display_name = optional(string)
    description  = optional(string)
  }))
  default = [{ name = "main", display_name = "Main project" }]
}

variable "model_deployments" {
  description = "Model deployments. Check model availability/retirement for your region before deploying."
  type = list(object({
    name     = string
    model    = string
    version  = string
    format   = optional(string, "OpenAI")
    sku_name = optional(string, "GlobalStandard")
    capacity = optional(number, 10)
  }))
  default = [
    { name = "gpt-4.1-mini", model = "gpt-4.1-mini", version = "2025-04-14", capacity = 10 },
    { name = "text-embedding-3-large", model = "text-embedding-3-large", version = "1", sku_name = "Standard", capacity = 10 },
  ]
}

variable "enable_ai_search" {
  description = "Deploy Azure AI Search."
  type        = bool
  default     = true
}

variable "ai_search_sku" {
  description = "AI Search SKU (basic or higher)."
  type        = string
  default     = "standard"
}

variable "ai_search_replica_count" {
  description = "AI Search replicas."
  type        = number
  default     = 1
}

variable "enable_ml_workspace" {
  description = "Deploy an Azure Machine Learning workspace."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Serving
# ---------------------------------------------------------------------------
variable "enable_aks" {
  description = "Deploy the private AKS cluster."
  type        = bool
  default     = true
}

variable "aks_sku_tier" {
  description = "AKS tier: Free or Standard."
  type        = string
  default     = "Standard"
}

variable "aks_admin_group_object_ids" {
  description = "Entra groups with AKS cluster-admin rights."
  type        = list(string)
  default     = []
}

variable "aks_grant_deployer_cluster_admin" {
  description = "Grant the deploying identity AKS RBAC Cluster Admin."
  type        = bool
  default     = false
}

variable "aks_system_node_count" {
  description = "System node pool min/max."
  type        = object({ min = number, max = number })
  default     = { min = 2, max = 3 }
}

variable "aks_user_node_count" {
  description = "User node pool min/max."
  type        = object({ min = number, max = number })
  default     = { min = 1, max = 5 }
}

variable "aks_node_vm_size" {
  description = "VM size for AKS node pools."
  type        = string
  default     = "Standard_D4ds_v5"
}

variable "enable_purview" {
  description = "Deploy Microsoft Purview."
  type        = bool
  default     = false
}
