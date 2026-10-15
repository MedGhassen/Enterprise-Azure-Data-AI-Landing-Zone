variable "name_prefix" {
  description = "Prefix for resource names, e.g. `dataai-dev-weu`."
  type        = string
}

variable "name_suffix" {
  description = "Instance suffix for resource names, e.g. `001`."
  type        = string
}

variable "unique_suffix" {
  description = "Short random suffix used for globally unique names."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for databases."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "tenant_id" {
  description = "Entra tenant ID."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Subnet for the database private endpoints."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs keyed by zone name (from the networking module)."
  type        = map(string)
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics and auditing."
  type        = string
}

# Azure SQL
variable "enable_sql" {
  description = "Deploy Azure SQL server + database."
  type        = bool
  default     = true
}

variable "entra_admin_object_id" {
  description = "Object ID of the Entra user/group that administers the SQL server."
  type        = string
}

variable "entra_admin_login" {
  description = "Display name of the Entra SQL administrator."
  type        = string
  default     = "sql-entra-admin"
}

variable "sql_database_sku" {
  description = "Azure SQL database SKU (e.g. GP_S_Gen5_1 serverless, S0, GP_Gen5_2)."
  type        = string
  default     = "GP_S_Gen5_1"
}

# Cosmos DB
variable "enable_cosmos" {
  description = "Deploy Cosmos DB (NoSQL)."
  type        = bool
  default     = true
}

variable "cosmos_serverless" {
  description = "Use serverless capacity mode (no failover regions, no autoscale)."
  type        = bool
  default     = false
}

variable "cosmos_consistency_level" {
  description = "Cosmos DB consistency level."
  type        = string
  default     = "Session"
}

variable "cosmos_zone_redundant" {
  description = "Zone redundancy for the primary region."
  type        = bool
  default     = false
}

variable "cosmos_failover_locations" {
  description = "Additional regions for geo-replication, in failover priority order."
  type        = list(string)
  default     = []
}

variable "cosmos_autoscale_max_throughput" {
  description = "Autoscale max RU/s for the default container (provisioned mode)."
  type        = number
  default     = 1000
}
