# ADLS Gen2 account: HNS, Entra ID only (no shared keys), private endpoints only.
resource "azurerm_storage_account" "main" {
  name                              = "stdl${substr(replace(var.name_prefix, "-", ""), 0, 13)}${var.unique_suffix}${var.name_suffix}"
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_tier                      = "Standard"
  account_replication_type          = var.replication
  account_kind                      = "StorageV2"
  is_hns_enabled                    = true
  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  shared_access_key_enabled         = false
  default_to_oauth_authentication   = true
  public_network_access_enabled     = false
  allow_nested_items_to_be_public   = false
  cross_tenant_replication_enabled  = false
  infrastructure_encryption_enabled = true
  tags                              = var.tags

  blob_properties {
    delete_retention_policy {
      days = var.blob_soft_delete_retention_days
    }
    container_delete_retention_policy {
      days = var.container_soft_delete_retention_days
    }
  }

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }
}

# Containers are created through the control plane (storage_account_id), so
# Terraform keeps working although the data plane is private.
resource "azurerm_storage_container" "filesystems" {
  for_each              = toset(var.filesystems)
  name                  = each.value
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

# Lifecycle: tier raw data to Cool, then Archive.
resource "azurerm_storage_management_policy" "main" {
  storage_account_id = azurerm_storage_account.main.id

  rule {
    name    = "raw-to-cool-archive"
    enabled = true
    filters {
      prefix_match = ["raw/"]
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

resource "azurerm_private_endpoint" "this" {
  for_each            = toset(["blob", "dfs"])
  name                = "${var.name_prefix}-st-${each.key}-pe-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${each.key}-psc"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = [each.key]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.${each.key}.core.windows.net"]]
  }
}

resource "azurerm_monitor_diagnostic_setting" "blob" {
  name                       = "diag-to-law"
  target_resource_id         = "${azurerm_storage_account.main.id}/blobServices/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  enabled_metric {
    category = "Transaction"
  }
}
