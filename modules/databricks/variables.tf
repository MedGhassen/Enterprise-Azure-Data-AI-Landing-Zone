variable "name_prefix" {
  description = "Prefix for resource names, e.g. `dataai-dev-weu`."
  type        = string
}

variable "name_suffix" {
  description = "Instance suffix for resource names, e.g. `001`."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for Databricks."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "virtual_network_id" {
  description = "Spoke VNet ID used for VNet injection."
  type        = string
}

variable "private_subnet_name" {
  description = "Name of the delegated private (container) subnet."
  type        = string
}

variable "public_subnet_name" {
  description = "Name of the delegated public (host) subnet."
  type        = string
}

variable "private_subnet_nsg_association_id" {
  description = "NSG association ID of the private subnet."
  type        = string
}

variable "public_subnet_nsg_association_id" {
  description = "NSG association ID of the public subnet."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Subnet for the workspace private endpoints."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs keyed by zone name (from the networking module)."
  type        = map(string)
}

variable "storage_account_id" {
  description = "Data lake storage account ID (Unity Catalog access connector RBAC)."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics."
  type        = string
}

variable "public_network_access_enabled" {
  description = "Allow access to the workspace UI/API from the internet. Keep false for a fully private workspace."
  type        = bool
  default     = false
}

variable "create_browser_authentication_endpoint" {
  description = "Create the browser_authentication private endpoint (one per region is enough)."
  type        = bool
  default     = true
}
