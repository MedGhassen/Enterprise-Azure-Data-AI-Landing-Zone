# Region short codes for naming (e.g. West Europe -> weu)
locals {
  region_short = {
    "eastus"             = "eus"
    "eastus2"            = "eus2"
    "westus"             = "wus"
    "westus2"            = "wus2"
    "westeurope"         = "weu"
    "northeurope"        = "neu"
    "uksouth"            = "uks"
    "ukwest"             = "ukw"
    "southeastasia"      = "sea"
    "eastasia"           = "ea"
    "australiaeast"      = "aue"
    "canadacentral"      = "cac"
    "centralus"          = "cus"
    "northcentralus"     = "ncus"
    "southcentralus"     = "scus"
    "francecentral"      = "frc"
    "germanywestcentral" = "gwc"
    "swedencentral"      = "swc"
    "norwayeast"         = "noe"
  }
  region_short_code = lookup(local.region_short, lower(var.primary_region), "eus")
  instance_suffix   = var.instance_suffix != "" ? var.instance_suffix : "001"

  # Naming: {prefix}-{env}-{region_short}  (suffix = instance only)
  name_prefix = "${var.resource_prefix}-${var.environment}-${local.region_short_code}"
  name_suffix = local.instance_suffix

  common_tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
    cost_center = var.cost_center
    owner       = var.owner_email
  }
}
