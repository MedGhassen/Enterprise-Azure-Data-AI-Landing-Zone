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
  description = "Resource group for storage"
  type        = string
}

variable "subnet_id_private_endpoint" {
  description = "Subnet ID for private endpoints (snet-data)"
  type        = string
}

variable "private_dns_zone_id_blob" {
  description = "Private DNS zone ID for privatelink.blob.core.windows.net (optional - pass empty to skip A record)"
  type        = string
  default     = ""
}

variable "private_dns_zone_id_dfs" {
  description = "Private DNS zone ID for privatelink.dfs.core.windows.net (optional)"
  type        = string
  default     = ""
}

variable "private_dns_zone_blob_name" {
  description = "Private DNS zone name for blob (to create A record)"
  type        = string
  default     = ""
}

variable "private_dns_zone_blob_rg" {
  description = "Resource group of blob private DNS zone"
  type        = string
  default     = ""
}

variable "private_dns_zone_dfs_name" {
  description = "Private DNS zone name for dfs"
  type        = string
  default     = ""
}

variable "private_dns_zone_dfs_rg" {
  description = "Resource group of dfs private DNS zone"
  type        = string
  default     = ""
}

variable "replication" {
  description = "Storage account replication (GRS, RAGRS, LRS, etc.)"
  type        = string
  default     = "GRS"
}

variable "blob_soft_delete_retention_days" {
  description = "Blob soft delete retention in days"
  type        = number
  default     = 30
}

variable "container_soft_delete_retention_days" {
  description = "Container soft delete retention in days"
  type        = number
  default     = 30
}

variable "lifecycle_cool_after_days" {
  description = "Move blob to Cool tier after N days"
  type        = number
  default     = 90
}

variable "lifecycle_archive_after_days" {
  description = "Move blob to Archive tier after N days"
  type        = number
  default     = 365
}
