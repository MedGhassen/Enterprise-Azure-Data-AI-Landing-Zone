locals {
  # Supported regions: short code used in names + display name used by Service Health alerts.
  regions = {
    australiaeast      = { short = "aue", display = "Australia East" }
    brazilsouth        = { short = "brs", display = "Brazil South" }
    canadacentral      = { short = "cac", display = "Canada Central" }
    centralindia       = { short = "inc", display = "Central India" }
    centralus          = { short = "cus", display = "Central US" }
    eastasia           = { short = "ea", display = "East Asia" }
    eastus             = { short = "eus", display = "East US" }
    eastus2            = { short = "eus2", display = "East US 2" }
    francecentral      = { short = "frc", display = "France Central" }
    germanywestcentral = { short = "gwc", display = "Germany West Central" }
    italynorth         = { short = "itn", display = "Italy North" }
    japaneast          = { short = "jpe", display = "Japan East" }
    northcentralus     = { short = "ncus", display = "North Central US" }
    northeurope        = { short = "neu", display = "North Europe" }
    norwayeast         = { short = "noe", display = "Norway East" }
    polandcentral      = { short = "plc", display = "Poland Central" }
    southcentralus     = { short = "scus", display = "South Central US" }
    southeastasia      = { short = "sea", display = "Southeast Asia" }
    spaincentral       = { short = "spc", display = "Spain Central" }
    swedencentral      = { short = "swc", display = "Sweden Central" }
    switzerlandnorth   = { short = "szn", display = "Switzerland North" }
    uksouth            = { short = "uks", display = "UK South" }
    ukwest             = { short = "ukw", display = "UK West" }
    westeurope         = { short = "weu", display = "West Europe" }
    westus             = { short = "wus", display = "West US" }
    westus2            = { short = "wus2", display = "West US 2" }
    westus3            = { short = "wus3", display = "West US 3" }
  }

  location = lower(var.location)
  region   = local.regions[local.location]

  # Naming: {prefix}-{env}-{region}-{type}-{instance}, e.g. dataai-dev-weu-hub-vnet-001.
  # Globally unique names additionally carry a short random suffix.
  name_prefix   = "${var.resource_prefix}-${var.environment}-${local.region.short}"
  name_suffix   = var.instance_suffix
  unique_suffix = coalesce(var.unique_suffix, random_string.unique.result)

  common_tags = merge(
    {
      project     = var.project_name
      environment = var.environment
      managed_by  = "terraform"
      cost_center = var.cost_center
      owner       = var.owner_email
    },
    var.additional_tags,
  )

  # Workload resource groups
  resource_groups = {
    network = "rg-${local.name_prefix}-network-${local.name_suffix}"
    shared  = "rg-${local.name_prefix}-shared-${local.name_suffix}"
    data    = "rg-${local.name_prefix}-data-${local.name_suffix}"
    ai      = "rg-${local.name_prefix}-ai-${local.name_suffix}"
    serving = "rg-${local.name_prefix}-serving-${local.name_suffix}"
  }

  # Entra principal that administers SQL/Synapse (defaults to the deploying identity).
  entra_admin_object_id = coalesce(var.entra_admin_object_id, data.azurerm_client_config.current.object_id)
  entra_admin_login     = var.entra_admin_object_id == null ? "terraform-deployer" : var.entra_admin_login
}

data "azurerm_client_config" "current" {}

resource "random_string" "unique" {
  length  = 4
  lower   = true
  upper   = false
  numeric = true
  special = false
}
