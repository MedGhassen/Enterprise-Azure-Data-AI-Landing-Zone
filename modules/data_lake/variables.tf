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
  description = "Resource group for the data lake."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "private_endpoint_subnet_id" {
  description = "Subnet for the blob/dfs private endpoints."
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

variable "replication" {
  description = "Replication type (LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS)."
  type        = string
  default     = "ZRS"
  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RAGRS", "GZRS", "RAGZRS"], var.replication)
    error_message = "replication must be one of LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS."
  }
}

variable "filesystems" {
  description = "ADLS Gen2 filesystems (containers) to create. Medallion layers plus Unity Catalog and Synapse workspace storage."
  type        = list(string)
  default     = ["raw", "curated", "enriched", "unity", "synapse"]
}

variable "blob_soft_delete_retention_days" {
  description = "Blob soft-delete retention in days."
  type        = number
  default     = 30
}

variable "container_soft_delete_retention_days" {
  description = "Container soft-delete retention in days."
  type        = number
  default     = 30
}

variable "lifecycle_cool_after_days" {
  description = "Days after last modification before raw blobs move to Cool."
  type        = number
  default     = 90
}

variable "lifecycle_archive_after_days" {
  description = "Days after last modification before raw blobs move to Archive."
  type        = number
  default     = 365
}
