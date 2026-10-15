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
  description = "Resource group for serving"
  type        = string
}

variable "subnet_id_aks" {
  description = "Subnet for AKS (snet-serving)"
  type        = string
}

variable "subnet_id_acr_pe" {
  description = "Subnet for ACR private endpoint (snet-serving or snet-security)"
  type        = string
  default     = ""
}

variable "enable_acr_private_endpoint" {
  description = "Create private endpoint for ACR"
  type        = bool
  default     = true
}

variable "aks_system_node_pool_vm_size" {
  type    = string
  default = "Standard_DS2_v2"
}

variable "aks_user_node_pool_vm_size" {
  type    = string
  default = "Standard_DS3_v2"
}

variable "aks_user_node_pool_min_count" {
  type    = number
  default = 1
}

variable "aks_user_node_pool_max_count" {
  type    = number
  default = 5
}

variable "acr_sku" {
  type    = string
  default = "Premium"
}

variable "enable_purview" {
  description = "Enable Microsoft Purview"
  type        = bool
  default     = false
}

variable "private_dns_zone_acr_name" {
  type    = string
  default = ""
}

variable "private_dns_zone_acr_rg" {
  type    = string
  default = ""
}

variable "log_analytics_workspace_id" {
  type    = string
  default = ""
}
