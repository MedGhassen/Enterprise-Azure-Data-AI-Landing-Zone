variable "name_prefix" {
  description = "Prefix for resource names, e.g. `dataai-dev-weu`."
  type        = string
}

variable "name_suffix" {
  description = "Instance suffix for resource names, e.g. `001`."
  type        = string
}

variable "unique_suffix" {
  description = "Short random suffix used for globally unique names (flow log storage account)."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for networking resources."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "availability_zones" {
  description = "Availability zones for zonal resources (Firewall, public IPs). Use [] in regions without zones."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "hub_vnet_address_space" {
  description = "Hub VNet address space."
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.hub_vnet_address_space, 0))
    error_message = "hub_vnet_address_space must be a valid CIDR."
  }
}

variable "spoke_vnet_address_space" {
  description = "Spoke VNet address space."
  type        = string
  default     = "10.1.0.0/16"
  validation {
    condition     = can(cidrhost(var.spoke_vnet_address_space, 0))
    error_message = "spoke_vnet_address_space must be a valid CIDR."
  }
}

variable "subnet_cidrs" {
  description = "Subnet CIDRs. Hub: firewall (min /26), bastion (min /26), gateway (min /27), dns_resolver_inbound (min /28). Spoke: the rest."
  type = object({
    firewall             = optional(string, "10.0.1.0/26")
    bastion              = optional(string, "10.0.2.0/26")
    gateway              = optional(string, "10.0.3.0/27")
    dns_resolver_inbound = optional(string, "10.0.4.0/28")
    data                 = optional(string, "10.1.1.0/24")
    databricks_private   = optional(string, "10.1.2.0/24")
    databricks_public    = optional(string, "10.1.3.0/24")
    ai                   = optional(string, "10.1.4.0/24")
    serving              = optional(string, "10.1.5.0/24")
    security             = optional(string, "10.1.6.0/24")
  })
  default = {}
  validation {
    condition     = alltrue([for c in values(var.subnet_cidrs) : can(cidrhost(c, 0))])
    error_message = "All subnet_cidrs must be valid CIDRs."
  }
}

variable "enable_firewall" {
  description = "Deploy Azure Firewall + policy in the hub and route the serving (AKS) subnet through it."
  type        = bool
  default     = true
}

variable "firewall_sku" {
  description = "Azure Firewall tier (Standard or Premium)."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.firewall_sku)
    error_message = "firewall_sku must be Standard or Premium."
  }
}

variable "firewall_threat_intel_mode" {
  description = "Threat intelligence mode for the firewall policy (Off, Alert, Deny)."
  type        = string
  default     = "Alert"
  validation {
    condition     = contains(["Off", "Alert", "Deny"], var.firewall_threat_intel_mode)
    error_message = "firewall_threat_intel_mode must be Off, Alert or Deny."
  }
}

variable "enable_bastion" {
  description = "Deploy Azure Bastion in the hub."
  type        = bool
  default     = false
}

variable "bastion_sku" {
  description = "Azure Bastion SKU (Basic, Standard, Premium)."
  type        = string
  default     = "Basic"
}

variable "enable_vpn_gateway" {
  description = "Deploy a P2S VPN Gateway (Entra ID auth) and a DNS Private Resolver in the hub."
  type        = bool
  default     = false
}

variable "vpn_gateway_sku" {
  description = "VPN Gateway SKU. Zone-redundant (AZ) SKUs are recommended; non-AZ SKUs are being retired."
  type        = string
  default     = "VpnGw1AZ"
  validation {
    condition     = can(regex("^VpnGw[1-5](AZ)?$", var.vpn_gateway_sku))
    error_message = "vpn_gateway_sku must be a valid VPN Gateway SKU (e.g. VpnGw1AZ)."
  }
}

variable "vpn_client_address_pool" {
  description = "Address pool for P2S VPN clients (must not overlap hub/spoke)."
  type        = string
  default     = "172.16.0.0/24"
  validation {
    condition     = can(cidrhost(var.vpn_client_address_pool, 0))
    error_message = "vpn_client_address_pool must be a valid CIDR."
  }
}

variable "vpn_aad_audience" {
  description = "Application ID of the Azure VPN client. Default is the Microsoft-registered Azure VPN Client app (no admin consent needed); the legacy value is 41b23e61-6c1e-4545-b367-cd054e0ed4b4."
  type        = string
  default     = "c632b3df-fb67-4d84-bdcf-b95ad541b5c8"
}

variable "enable_nat_gateway" {
  description = "Attach a NAT Gateway to the Databricks subnets for outbound connectivity."
  type        = bool
  default     = true
}

variable "private_dns_zone_names" {
  description = "Private DNS zones to create and link to hub and spoke."
  type        = list(string)
  default = [
    "privatelink.blob.core.windows.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.sql.azuresynapse.net",
    "privatelink.dev.azuresynapse.net",
    "privatelink.azuresynapse.net",
    "privatelink.database.windows.net",
    "privatelink.documents.azure.com",
    "privatelink.servicebus.windows.net",
    "privatelink.datafactory.azure.net",
    "privatelink.adf.azure.com",
    "privatelink.azuredatabricks.net",
    "privatelink.api.azureml.ms",
    "privatelink.notebooks.azure.net",
    "privatelink.cognitiveservices.azure.com",
    "privatelink.openai.azure.com",
    "privatelink.services.ai.azure.com",
    "privatelink.search.windows.net",
    "privatelink.azurecr.io",
    "privatelink.purview.azure.com",
    "privatelink.purviewstudio.azure.com",
  ]
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID (diagnostics, Traffic Analytics)."
  type        = string
}

variable "log_analytics_workspace_guid" {
  description = "Log Analytics workspace (customer) ID, required by Traffic Analytics."
  type        = string
}

variable "enable_flow_logs" {
  description = "Enable VNet flow logs with Traffic Analytics for hub and spoke."
  type        = bool
  default     = false
}

variable "create_network_watcher" {
  description = "Create the Network Watcher (only if automatic creation is disabled in the subscription)."
  type        = bool
  default     = false
}

variable "network_watcher_name" {
  description = "Network Watcher name. Azure's auto-created watcher is NetworkWatcher_<region>."
  type        = string
  default     = null
}

variable "network_watcher_resource_group_name" {
  description = "Resource group of the Network Watcher."
  type        = string
  default     = "NetworkWatcherRG"
}

variable "flow_log_retention_days" {
  description = "Flow log retention in days."
  type        = number
  default     = 90
}
