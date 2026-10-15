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
  description = "Prefix for resource names (e.g. dataai-dataai-dev-weu)"
  type        = string
}

variable "name_suffix" {
  description = "Suffix for resource names (e.g. weu-001)"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "Resource group for networking resources"
  type        = string
}

variable "hub_vnet_address_space" {
  description = "Hub VNet address space (CIDR)"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.hub_vnet_address_space, 0))
    error_message = "hub_vnet_address_space must be a valid CIDR."
  }
}

variable "spoke_vnet_address_space" {
  description = "Spoke VNet address space (single VNet for data, AI, serving)"
  type        = string
  default     = "10.1.0.0/16"
  validation {
    condition     = can(cidrhost(var.spoke_vnet_address_space, 0))
    error_message = "spoke_vnet_address_space must be a valid CIDR."
  }
}

variable "subnet_data_cidr" {
  description = "CIDR for snet-data"
  type        = string
  default     = "10.1.1.0/24"
}

variable "subnet_databricks_private_cidr" {
  description = "CIDR for Databricks private subnet"
  type        = string
  default     = "10.1.2.0/24"
}

variable "subnet_databricks_public_cidr" {
  description = "CIDR for Databricks public subnet"
  type        = string
  default     = "10.1.3.0/24"
}

variable "subnet_ai_cidr" {
  description = "CIDR for snet-ai"
  type        = string
  default     = "10.1.4.0/24"
}

variable "subnet_serving_cidr" {
  description = "CIDR for snet-serving"
  type        = string
  default     = "10.1.5.0/24"
}

variable "subnet_security_cidr" {
  description = "CIDR for snet-security"
  type        = string
  default     = "10.1.6.0/24"
}

variable "firewall_subnet_cidr" {
  description = "CIDR for AzureFirewallSubnet (min /26)"
  type        = string
  default     = "10.0.1.0/26"
}

variable "bastion_subnet_cidr" {
  description = "CIDR for AzureBastionSubnet (min /26)"
  type        = string
  default     = "10.0.2.0/26"
}

variable "gateway_subnet_cidr" {
  description = "CIDR for GatewaySubnet"
  type        = string
  default     = "10.0.3.0/27"
}

variable "enable_bastion" {
  description = "Create Azure Bastion"
  type        = bool
  default     = false
}

variable "enable_gateway" {
  description = "Create Gateway subnet, VPN Gateway (P2S) and DNS Private Resolver"
  type        = bool
  default     = false
}

# ── VPN P2S variables ──────────────────────────────────────────────────────

variable "vpn_gateway_sku" {
  description = "VPN Gateway SKU (VpnGw1, VpnGw2, VpnGw3, VpnGw1AZ, etc.)"
  type        = string
  default     = "VpnGw1"
  validation {
    condition     = can(regex("^VpnGw[1-5](AZ)?$", var.vpn_gateway_sku))
    error_message = "vpn_gateway_sku must be a valid VPN Gateway SKU (e.g. VpnGw1, VpnGw2AZ)."
  }
}

variable "vpn_client_address_pool" {
  description = "Address pool for P2S VPN clients (must not overlap with hub/spoke CIDRs)"
  type        = string
  default     = "172.16.0.0/24"
  validation {
    condition     = can(cidrhost(var.vpn_client_address_pool, 0))
    error_message = "vpn_client_address_pool must be a valid CIDR."
  }
}

variable "vpn_aad_audience" {
  description = "Azure VPN Enterprise Application ID for Entra ID auth (public cloud default)"
  type        = string
  default     = "41b23e61-6c1e-4545-b367-cd054e0ed4b4"
}

variable "dns_resolver_inbound_subnet_cidr" {
  description = "CIDR for DNS Private Resolver inbound endpoint subnet in hub (min /28)"
  type        = string
  default     = "10.0.4.0/28"
}

variable "firewall_sku" {
  description = "Azure Firewall SKU (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.firewall_sku)
    error_message = "firewall_sku must be Basic, Standard, or Premium."
  }
}

variable "private_dns_zone_names" {
  description = "List of private DNS zone names to create and link to hub"
  type        = list(string)
  default = [
    "privatelink.blob.core.windows.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.sql.azuresynapse.net",
    "privatelink.dev.azuresynapse.net",
    "privatelink.azuresynapse.net",
    "privatelink.database.windows.net",
    "privatelink.cognitiveservices.azure.com",
    "privatelink.openai.azure.com",
    "privatelink.search.windows.net",
    "privatelink.api.azureml.ms",
    "privatelink.azuredatabricks.net",
    "privatelink.datafactory.azure.net",
    "privatelink.azurecr.io",
    "privatelink.eventhub.azure.net",
    "privatelink.documents.azure.net",
    "privatelink.postgres.database.azure.com"
  ]
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for NSG flow logs (optional)"
  type        = string
  default     = ""
}

variable "flow_log_storage_account_id" {
  description = "Storage account ID for NSG flow logs (optional)"
  type        = string
  default     = ""
}

variable "flow_log_retention_days" {
  description = "NSG flow log retention in days"
  type        = number
  default     = 90
}
