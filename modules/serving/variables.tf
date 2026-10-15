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
  description = "Resource group for serving resources."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "availability_zones" {
  description = "Availability zones for AKS node pools. Use null in regions without zones."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "private_endpoint_subnet_id" {
  description = "Subnet for ACR/Purview private endpoints."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs keyed by zone name (from the networking module)."
  type        = map(string)
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics and Container Insights."
  type        = string
}

variable "storage_account_id" {
  description = "Data lake storage account ID (Purview scanning)."
  type        = string
}

variable "acr_zone_redundancy_enabled" {
  description = "Zone-redundant ACR (cannot be changed after creation)."
  type        = bool
  default     = true
}

# AKS
variable "enable_aks" {
  description = "Deploy the AKS cluster."
  type        = bool
  default     = true
}

variable "aks_subnet_id" {
  description = "Subnet for AKS nodes (snet-serving)."
  type        = string
}

variable "egress_via_firewall" {
  description = "Use userDefinedRouting egress through the hub firewall (requires route_table_id)."
  type        = bool
  default     = false
}

variable "route_table_id" {
  description = "Route table attached to the AKS subnet (required when egress_via_firewall = true)."
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "Kubernetes version (null = AKS default). Patch upgrades are automatic."
  type        = string
  default     = null
}

variable "aks_sku_tier" {
  description = "AKS control plane tier: Free (dev) or Standard (SLA)."
  type        = string
  default     = "Standard"
}

variable "aks_admin_group_object_ids" {
  description = "Entra group object IDs with cluster-admin rights."
  type        = list(string)
  default     = []
}

variable "grant_deployer_cluster_admin" {
  description = "Grant the deploying principal 'Azure Kubernetes Service RBAC Cluster Admin'."
  type        = bool
  default     = false
}

variable "aks_pod_cidr" {
  description = "Pod CIDR for CNI Overlay (must not overlap the VNets)."
  type        = string
  default     = "192.168.0.0/16"
}

variable "aks_service_cidr" {
  description = "Kubernetes service CIDR (must not overlap the VNets)."
  type        = string
  default     = "172.17.0.0/16"
}

variable "system_node_vm_size" {
  description = "VM size for the system node pool."
  type        = string
  default     = "Standard_D4ds_v5"
}

variable "system_node_min_count" {
  description = "Minimum system nodes."
  type        = number
  default     = 2
}

variable "system_node_max_count" {
  description = "Maximum system nodes."
  type        = number
  default     = 3
}

variable "user_node_vm_size" {
  description = "VM size for the user node pool."
  type        = string
  default     = "Standard_D4ds_v5"
}

variable "user_node_min_count" {
  description = "Minimum user nodes."
  type        = number
  default     = 1
}

variable "user_node_max_count" {
  description = "Maximum user nodes."
  type        = number
  default     = 5
}

# Purview
variable "enable_purview" {
  description = "Deploy Microsoft Purview."
  type        = bool
  default     = false
}
