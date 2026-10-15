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
  description = "Resource group for Synapse."
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

variable "entra_admin_object_id" {
  description = "Object ID of the Entra user/group that is Synapse SQL administrator."
  type        = string
}

variable "entra_admin_login" {
  description = "Display name of the Entra SQL administrator."
  type        = string
  default     = "sql-entra-admin"
}

variable "storage_account_id" {
  description = "Data lake storage account ID (RBAC for the workspace identity)."
  type        = string
}

variable "data_lake_filesystem_id" {
  description = "Primary ADLS Gen2 filesystem URL, e.g. https://<account>.dfs.core.windows.net/synapse."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Subnet for the Synapse private endpoints."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs keyed by zone name (from the networking module)."
  type        = map(string)
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics."
  type        = string
}

variable "data_exfiltration_protection_enabled" {
  description = "Restrict managed VNet outbound traffic to approved targets (cannot be changed after creation)."
  type        = bool
  default     = false
}

variable "enable_sql_pool" {
  description = "Create a dedicated SQL pool (billed while running)."
  type        = bool
  default     = false
}

variable "sql_pool_sku" {
  description = "Dedicated SQL pool SKU."
  type        = string
  default     = "DW100c"
}

variable "spark_node_size" {
  description = "Spark node size (Small, Medium, Large, ...)."
  type        = string
  default     = "Small"
}

variable "spark_version" {
  description = "Spark runtime version."
  type        = string
  default     = "3.4"
}

variable "spark_min_nodes" {
  description = "Minimum Spark nodes."
  type        = number
  default     = 3
}

variable "spark_max_nodes" {
  description = "Maximum Spark nodes."
  type        = number
  default     = 10
}

variable "spark_auto_pause_minutes" {
  description = "Idle minutes before the Spark pool pauses."
  type        = number
  default     = 15
}
