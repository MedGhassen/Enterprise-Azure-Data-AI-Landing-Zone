# Custom parameters for no public IP (secure cluster connectivity)
locals {
  custom_params = {
    enableNoPublicIp = var.no_public_ip
  }
}

resource "azurerm_databricks_workspace" "main" {
  name                        = "${var.name_prefix}-dbw-${var.name_suffix}"
  resource_group_name         = var.resource_group_name
  location                    = var.primary_region
  sku                         = "premium"
  managed_resource_group_name = "${var.name_prefix}-dbw-mrg-${var.name_suffix}"
  tags                        = var.tags

  custom_parameters {
    no_public_ip                                         = var.no_public_ip
    virtual_network_id                                   = split("/subnets/", var.subnet_id_private)[0]
    public_subnet_name                                   = split("/", var.subnet_id_public)[length(split("/", var.subnet_id_public)) - 1]
    private_subnet_name                                  = split("/", var.subnet_id_private)[length(split("/", var.subnet_id_private)) - 1]
    public_subnet_network_security_group_association_id  = var.nsg_association_id_public
    private_subnet_network_security_group_association_id = var.nsg_association_id_private
  }

  depends_on = []
}

# Private endpoint for Databricks workspace (databricks_ui_api subresource)
resource "azurerm_private_endpoint" "workspace" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.name_prefix}-dbw-pe-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_private_endpoint
  tags                = var.tags

  private_service_connection {
    name                           = "dbw-psc"
    private_connection_resource_id = azurerm_databricks_workspace.main.id
    subresource_names              = ["databricks_ui_api"]
    is_manual_connection           = false
  }
}

# Private DNS A record for workspace (front-end hostname)
locals {
  databricks_host = replace(replace(azurerm_databricks_workspace.main.workspace_url, "https://", ""), "/", "")
  dns_rg          = var.private_dns_zone_databricks_rg != "" ? var.private_dns_zone_databricks_rg : var.resource_group_name
}

resource "azurerm_private_dns_a_record" "workspace" {
  count               = var.enable_private_endpoint && var.private_dns_zone_databricks_name != "" ? 1 : 0
  name                = split(".", local.databricks_host)[0]
  zone_name           = var.private_dns_zone_databricks_name
  resource_group_name = local.dns_rg
  ttl                 = 300
  records             = [azurerm_private_endpoint.workspace[0].private_service_connection[0].private_ip_address]
}

# Unity Catalog metastore: create via Databricks provider (databricks_metastore) after workspace exists; storage_root = abfss://unity@<storage>.dfs.core.windows.net
