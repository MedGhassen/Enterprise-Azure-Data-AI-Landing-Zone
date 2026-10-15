data "azurerm_client_config" "current" {}

# ---------------------------------------------------------------------------
# Azure Container Registry: Premium (required for private endpoints), no admin user
# ---------------------------------------------------------------------------
resource "azurerm_container_registry" "main" {
  name                          = "cr${replace(var.name_prefix, "-", "")}${var.unique_suffix}${var.name_suffix}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = "Premium"
  admin_enabled                 = false
  anonymous_pull_enabled        = false
  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"
  zone_redundancy_enabled       = var.acr_zone_redundancy_enabled
  tags                          = var.tags
}

resource "azurerm_private_endpoint" "acr" {
  name                = "${var.name_prefix}-acr-pe-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "acr-psc"
    private_connection_resource_id = azurerm_container_registry.main.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids["privatelink.azurecr.io"]]
  }
}

resource "azurerm_monitor_diagnostic_setting" "acr" {
  name                       = "diag-to-law"
  target_resource_id         = azurerm_container_registry.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}

# ---------------------------------------------------------------------------
# AKS: private cluster, Entra ID + Azure RBAC (no local accounts), CNI Overlay
# with Cilium, egress through the hub firewall when a route table is supplied.
# ---------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "aks" {
  count               = var.enable_aks ? 1 : 0
  name                = "${var.name_prefix}-aks-id-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Pre-created kubelet identity so AcrPull exists before the first node starts.
resource "azurerm_user_assigned_identity" "kubelet" {
  count               = var.enable_aks ? 1 : 0
  name                = "${var.name_prefix}-aks-kubelet-id-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_role_assignment" "aks_kubelet_operator" {
  count                = var.enable_aks ? 1 : 0
  scope                = azurerm_user_assigned_identity.kubelet[0].id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.aks[0].principal_id
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  count                = var.enable_aks ? 1 : 0
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.kubelet[0].principal_id
}

# The control-plane identity manages the node subnet and the route table.
resource "azurerm_role_assignment" "aks_subnet" {
  count                = var.enable_aks ? 1 : 0
  scope                = var.aks_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks[0].principal_id
}

resource "azurerm_role_assignment" "aks_route_table" {
  count                = var.enable_aks && var.egress_via_firewall ? 1 : 0
  scope                = var.route_table_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks[0].principal_id
}

resource "azurerm_kubernetes_cluster" "main" {
  count                        = var.enable_aks ? 1 : 0
  name                         = "${var.name_prefix}-aks-${var.name_suffix}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  dns_prefix                   = "${var.name_prefix}-aks"
  node_resource_group          = "${var.name_prefix}-aks-nodes-${var.name_suffix}"
  kubernetes_version           = var.kubernetes_version
  sku_tier                     = var.aks_sku_tier
  private_cluster_enabled      = true
  local_account_disabled       = true
  azure_policy_enabled         = true
  oidc_issuer_enabled          = true
  workload_identity_enabled    = true
  automatic_upgrade_channel    = "patch"
  node_os_upgrade_channel      = "NodeImage"
  image_cleaner_enabled        = true
  image_cleaner_interval_hours = 48
  tags                         = var.tags

  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_node_vm_size
    vnet_subnet_id               = var.aks_subnet_id
    zones                        = var.availability_zones
    auto_scaling_enabled         = true
    min_count                    = var.system_node_min_count
    max_count                    = var.system_node_max_count
    os_sku                       = "AzureLinux"
    only_critical_addons_enabled = true
    temporary_name_for_rotation  = "systemtmp"

    upgrade_settings {
      max_surge = "33%"
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks[0].id]
  }

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.kubelet[0].client_id
    object_id                 = azurerm_user_assigned_identity.kubelet[0].principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.kubelet[0].id
  }

  azure_active_directory_role_based_access_control {
    tenant_id              = data.azurerm_client_config.current.tenant_id
    azure_rbac_enabled     = true
    admin_group_object_ids = var.aks_admin_group_object_ids
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"
    network_policy      = "cilium"
    load_balancer_sku   = "standard"
    outbound_type       = var.egress_via_firewall ? "userDefinedRouting" : "loadBalancer"
    pod_cidr            = var.aks_pod_cidr
    service_cidr        = var.aks_service_cidr
    dns_service_ip      = cidrhost(var.aks_service_cidr, 10)
  }

  oms_agent {
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    msi_auth_for_monitoring_enabled = true
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count, kubernetes_version]
  }

  depends_on = [
    azurerm_role_assignment.aks_subnet,
    azurerm_role_assignment.aks_route_table,
    azurerm_role_assignment.aks_kubelet_operator,
    azurerm_role_assignment.aks_acr_pull,
  ]
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  count                 = var.enable_aks ? 1 : 0
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main[0].id
  vm_size               = var.user_node_vm_size
  vnet_subnet_id        = var.aks_subnet_id
  zones                 = var.availability_zones
  auto_scaling_enabled  = true
  min_count             = var.user_node_min_count
  max_count             = var.user_node_max_count
  os_sku                = "AzureLinux"
  mode                  = "User"
  tags                  = var.tags

  upgrade_settings {
    max_surge = "33%"
  }

  lifecycle {
    ignore_changes = [node_count]
  }
}

# Optional: give the deploying principal cluster-admin through Azure RBAC.
resource "azurerm_role_assignment" "aks_deployer_admin" {
  count                = var.enable_aks && var.grant_deployer_cluster_admin ? 1 : 0
  scope                = azurerm_kubernetes_cluster.main[0].id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_monitor_diagnostic_setting" "aks" {
  count                          = var.enable_aks ? 1 : 0
  name                           = "diag-to-law"
  target_resource_id             = azurerm_kubernetes_cluster.main[0].id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category_group = "audit"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}

# ---------------------------------------------------------------------------
# Microsoft Purview (optional): data catalog/governance over the lake
# ---------------------------------------------------------------------------
resource "azurerm_purview_account" "main" {
  count                       = var.enable_purview ? 1 : 0
  name                        = "${var.name_prefix}-pview-${var.unique_suffix}-${var.name_suffix}"
  resource_group_name         = var.resource_group_name
  location                    = var.location
  managed_resource_group_name = "${var.name_prefix}-pview-mrg-${var.name_suffix}"
  public_network_enabled      = false
  managed_event_hub_enabled   = false
  tags                        = var.tags

  identity {
    type = "SystemAssigned"
  }
}

locals {
  purview_endpoints = var.enable_purview ? {
    account = "privatelink.purview.azure.com"
    portal  = "privatelink.purviewstudio.azure.com"
  } : {}
}

resource "azurerm_private_endpoint" "purview" {
  for_each            = local.purview_endpoints
  name                = "${var.name_prefix}-pview-${each.key}-pe-${var.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "pview-${each.key}-psc"
    private_connection_resource_id = azurerm_purview_account.main[0].id
    subresource_names              = [each.key]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_ids[each.value]]
  }
}

# Purview scans the lake with its managed identity.
resource "azurerm_role_assignment" "purview_lake" {
  count                = var.enable_purview ? 1 : 0
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_purview_account.main[0].identity[0].principal_id
}
