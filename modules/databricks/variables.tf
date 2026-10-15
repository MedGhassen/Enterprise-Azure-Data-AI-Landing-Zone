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
  description = "Resource group for Databricks"
  type        = string
}

variable "subnet_id_private" {
  description = "Private subnet ID for VNet injection"
  type        = string
}

variable "subnet_id_public" {
  description = "Public subnet ID for VNet injection"
  type        = string
}

variable "nsg_association_id_public" {
  description = "NSG association ID for the public Databricks subnet"
  type        = string
}

variable "nsg_association_id_private" {
  description = "NSG association ID for the private Databricks subnet"
  type        = string
}

variable "no_public_ip" {
  description = "Disable public IP for clusters (secure cluster connectivity)"
  type        = bool
  default     = true
}

variable "metastore_name" {
  description = "Unity Catalog metastore name"
  type        = string
  default     = "uc-metastore"
}

variable "catalog_name" {
  description = "Unity Catalog default catalog name"
  type        = string
  default     = "main"
}

variable "private_dns_zone_id_databricks" {
  description = "Private DNS zone ID for privatelink.azuredatabricks.net"
  type        = string
  default     = ""
}

variable "private_dns_zone_databricks_name" {
  description = "Private DNS zone name for Databricks"
  type        = string
  default     = ""
}

variable "private_dns_zone_databricks_rg" {
  description = "Resource group of Databricks private DNS zone"
  type        = string
  default     = ""
}

variable "subnet_id_private_endpoint" {
  description = "Subnet for Databricks workspace private endpoint (e.g. snet-data or snet-databricks-private)"
  type        = string
  default     = ""
}

variable "enable_private_endpoint" {
  description = "Create private endpoint for Databricks workspace"
  type        = bool
  default     = true
}

variable "resource_group_name_dns" {
  description = "Resource group for private DNS A record (if different)"
  type        = string
  default     = ""
}

variable "storage_account_name" {
  description = "Storage account name for Unity Catalog metastore (container 'unity' must exist)"
  type        = string
  default     = ""
}
