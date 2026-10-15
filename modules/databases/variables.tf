variable "project_name" {
  description = "Project name for naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "primary_region" {
  description = "Azure region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "name_suffix" {
  description = "Suffix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "Resource group for databases"
  type        = string
}

variable "subnet_id_sql_pe" {
  description = "Subnet for SQL private endpoint"
  type        = string
}

variable "subnet_id_cosmos_pe" {
  description = "Subnet for Cosmos DB private endpoint"
  type        = string
  default     = ""
}

variable "sql_server_version" {
  description = "SQL Server version"
  type        = string
  default     = "12.0"
}

variable "sql_database_sku" {
  description = "Azure SQL database SKU (e.g. S0, P1)"
  type        = string
  default     = "S0"
}

variable "sql_use_elastic_pool" {
  description = "Use elastic pool for SQL databases"
  type        = bool
  default     = false
}

variable "sql_elastic_pool_sku" {
  description = "Elastic pool SKU (e.g. StandardPool, BasicPool)"
  type        = string
  default     = "StandardPool"
}

variable "sql_elastic_pool_capacity" {
  description = "Elastic pool DTU or vCore capacity"
  type        = number
  default     = 100
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for SQL auditing"
  type        = string
  default     = ""
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for SQL"
  type        = bool
  default     = true
}

variable "private_dns_zone_sql_name" {
  description = "Private DNS zone name for database.windows.net"
  type        = string
  default     = ""
}

variable "private_dns_zone_sql_rg" {
  description = "Resource group of SQL private DNS zone"
  type        = string
  default     = ""
}

variable "cosmos_consistency_level" {
  description = "Cosmos DB consistency level"
  type        = string
  default     = "Session"
}

variable "cosmos_locations" {
  description = "List of {location, failover_priority} for Cosmos DB"
  type = list(object({
    location          = string
    failover_priority = number
  }))
  default = []
}

variable "cosmos_enable_autoscale" {
  description = "Enable autoscale throughput for Cosmos DB"
  type        = bool
  default     = true
}

variable "cosmos_autoscale_max_throughput" {
  description = "Cosmos DB autoscale max throughput"
  type        = number
  default     = 4000
}

variable "private_dns_zone_cosmos_name" {
  description = "Private DNS zone name for documents.azure.net"
  type        = string
  default     = ""
}

variable "private_dns_zone_cosmos_rg" {
  description = "Resource group of Cosmos private DNS zone"
  type        = string
  default     = ""
}

variable "aad_admin_object_ids" {
  description = "Azure AD object IDs for SQL AAD admin (AAD-only auth)"
  type        = list(string)
  default     = []
}
