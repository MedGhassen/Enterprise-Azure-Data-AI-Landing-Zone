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
  description = "Resource group for Synapse"
  type        = string
}

variable "storage_account_id" {
  description = "ADLS Gen2 storage account ID (for default data lake)"
  type        = string
}

variable "storage_account_name" {
  description = "Storage account name (for filesystem path)"
  type        = string
}

variable "data_lake_filesystem_name" {
  description = "Default filesystem/container name (e.g. raw or curated)"
  type        = string
  default     = "curated"
}

variable "sql_admin_login" {
  description = "SQL admin login (AAD-only recommended; this for legacy)"
  type        = string
  default     = ""
}

variable "sql_admin_password" {
  description = "SQL admin password (avoid if using AAD-only)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aad_admin_object_ids" {
  description = "Azure AD object IDs for Synapse AAD admin"
  type        = list(string)
  default     = []
}

variable "sql_pool_sku" {
  description = "Dedicated SQL pool SKU (e.g. DW100c)"
  type        = string
  default     = "DW100c"
}

variable "sql_collation" {
  description = "SQL collation"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "spark_pool_node_count" {
  description = "Spark pool initial node count"
  type        = number
  default     = 3
}

variable "spark_pool_min_nodes" {
  description = "Spark pool autoscale min"
  type        = number
  default     = 3
}

variable "spark_pool_max_nodes" {
  description = "Spark pool autoscale max"
  type        = number
  default     = 10
}

variable "spark_pool_auto_pause_delay" {
  description = "Spark pool auto-pause delay in minutes"
  type        = number
  default     = 15
}

variable "spark_version" {
  description = "Spark runtime version"
  type        = string
  default     = "3.4"
}

variable "spark_node_size" {
  description = "Spark node size (Memory Optimized)"
  type        = string
  default     = "Medium"
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = ""
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for Synapse"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Create private endpoint for Synapse SQL"
  type        = bool
  default     = true
}

variable "subnet_id_private_endpoint" {
  description = "Subnet for Synapse private endpoints"
  type        = string
  default     = ""
}

variable "private_dns_zone_ids_synapse" {
  description = "Map or list of private DNS zone IDs for Synapse (sql, dev, azuresynapse)"
  type        = map(string)
  default     = {}
}

variable "private_dns_zone_sql_name" {
  type    = string
  default = ""
}

variable "private_dns_zone_sql_rg" {
  type    = string
  default = ""
}

variable "private_dns_zone_dev_name" {
  type    = string
  default = ""
}

variable "private_dns_zone_dev_rg" {
  type    = string
  default = ""
}

variable "private_dns_zone_azuresynapse_name" {
  type    = string
  default = ""
}

variable "private_dns_zone_azuresynapse_rg" {
  type    = string
  default = ""
}
