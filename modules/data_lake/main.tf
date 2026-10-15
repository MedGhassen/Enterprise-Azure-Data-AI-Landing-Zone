# Storage account name: 3-24 chars, lowercase alphanumeric only
locals {
  storage_account_name = substr(lower(replace("st${var.name_prefix}${var.name_suffix}", "-", "")), 0, 24)
}

# ADLS Gen2 storage account
resource "azurerm_storage_account" "main" {
  name                     = local.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.primary_region
  account_tier             = "Standard"
  account_replication_type = var.replication
  account_kind             = "StorageV2"
  is_hns_enabled           = true
  min_tls_version          = "TLS1_2"
  tags                     = var.tags

  blob_properties {
    versioning_enabled = false
    delete_retention_policy {
      days = var.blob_soft_delete_retention_days
    }
    container_delete_retention_policy {
      days = var.container_soft_delete_retention_days
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [blob_properties, network_rules]
  }
}

resource "azurerm_storage_account_network_rules" "main" {
  storage_account_id         = azurerm_storage_account.main.id
  default_action             = "Deny"
  bypass                     = ["AzureServices"]
  virtual_network_subnet_ids = []
  ip_rules                   = []

  depends_on = [
    azurerm_storage_data_lake_gen2_filesystem.raw,
    azurerm_storage_data_lake_gen2_filesystem.curated,
    azurerm_storage_data_lake_gen2_filesystem.enriched,
    azurerm_storage_data_lake_gen2_filesystem.unity,
    azurerm_storage_data_lake_gen2_filesystem.eventhub_capture,
  ]
}

# Lifecycle management: move raw to Cool after 90d, Archive after 365d
resource "azurerm_storage_management_policy" "main" {
  storage_account_id = azurerm_storage_account.main.id

  rule {
    name    = "raw-to-cool-archive"
    enabled = true
    filters {
      prefix_match = ["raw"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = var.lifecycle_cool_after_days
        tier_to_archive_after_days_since_modification_greater_than = var.lifecycle_archive_after_days
      }
    }
  }
}

# Medallion filesystems
resource "azurerm_storage_data_lake_gen2_filesystem" "raw" {
  name               = "raw"
  storage_account_id = azurerm_storage_account.main.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "curated" {
  name               = "curated"
  storage_account_id = azurerm_storage_account.main.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "enriched" {
  name               = "enriched"
  storage_account_id = azurerm_storage_account.main.id
}

# Unity Catalog metastore (Databricks) and Event Hubs capture
resource "azurerm_storage_data_lake_gen2_filesystem" "unity" {
  name               = "unity"
  storage_account_id = azurerm_storage_account.main.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "eventhub_capture" {
  name               = "eventhub-capture"
  storage_account_id = azurerm_storage_account.main.id
}

# Private endpoints for blob and dfs
resource "azurerm_private_endpoint" "blob" {
  name                = "${var.name_prefix}-st-blob-pe-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_private_endpoint
  tags                = var.tags

  private_service_connection {
    name                           = "blob-psc"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "dfs" {
  name                = "${var.name_prefix}-st-dfs-pe-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_private_endpoint
  tags                = var.tags

  private_service_connection {
    name                           = "dfs-psc"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["dfs"]
    is_manual_connection           = false
  }
}

# Private DNS A records (zones created in networking; we need zone name + rg)
resource "azurerm_private_dns_a_record" "blob" {
  count               = var.private_dns_zone_blob_name != "" && var.private_dns_zone_blob_rg != "" ? 1 : 0
  name                = azurerm_storage_account.main.name
  zone_name           = var.private_dns_zone_blob_name
  resource_group_name = var.private_dns_zone_blob_rg
  ttl                 = 300
  records             = [azurerm_private_endpoint.blob.private_service_connection[0].private_ip_address]
}

resource "azurerm_private_dns_a_record" "dfs" {
  count               = var.private_dns_zone_dfs_name != "" && var.private_dns_zone_dfs_rg != "" ? 1 : 0
  name                = azurerm_storage_account.main.name
  zone_name           = var.private_dns_zone_dfs_name
  resource_group_name = var.private_dns_zone_dfs_rg
  ttl                 = 300
  records             = [azurerm_private_endpoint.dfs.private_service_connection[0].private_ip_address]
}
