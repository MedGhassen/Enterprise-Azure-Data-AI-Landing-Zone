# AKS - private cluster, Azure CNI, workload identity, attach ACR
resource "azurerm_kubernetes_cluster" "main" {
  name                    = "${var.name_prefix}-aks-${var.name_suffix}"
  location                = var.primary_region
  resource_group_name     = var.resource_group_name
  dns_prefix              = "aks-${var.name_prefix}"
  private_cluster_enabled = true
  tags                    = var.tags

  default_node_pool {
    name                = "system"
    vm_size             = var.aks_system_node_pool_vm_size
    vnet_subnet_id      = var.subnet_id_aks
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
    type                = "VirtualMachineScaleSets"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id != "" ? var.log_analytics_workspace_id : null
  }
}

# User node pool
# ACR pull role for AKS (cluster identity gets AcrPull on ACR)
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.identity[0].principal_id
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.aks_user_node_pool_vm_size
  vnet_subnet_id        = var.subnet_id_aks
  enable_auto_scaling   = true
  min_count             = var.aks_user_node_pool_min_count
  max_count             = var.aks_user_node_pool_max_count
}

# Azure Container Registry - Premium, private endpoint
resource "azurerm_container_registry" "main" {
  name                = "${replace(var.name_prefix, "-", "")}acr${replace(var.name_suffix, "-", "")}"
  resource_group_name = var.resource_group_name
  location            = var.primary_region
  sku                 = var.acr_sku
  admin_enabled       = false
  tags                = var.tags

  public_network_access_enabled = var.enable_acr_private_endpoint ? false : true
}

resource "azurerm_private_endpoint" "acr" {
  count               = var.enable_acr_private_endpoint ? 1 : 0
  name                = "${var.name_prefix}-acr-pe-${var.name_suffix}"
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_acr_pe
  tags                = var.tags

  private_service_connection {
    name                           = "acr-psc"
    private_connection_resource_id = azurerm_container_registry.main.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_a_record" "acr" {
  count               = var.enable_acr_private_endpoint && var.private_dns_zone_acr_name != "" && var.private_dns_zone_acr_rg != "" ? 1 : 0
  name                = azurerm_container_registry.main.name
  zone_name           = var.private_dns_zone_acr_name
  resource_group_name = var.private_dns_zone_acr_rg
  ttl                 = 300
  records             = [azurerm_private_endpoint.acr[0].private_service_connection[0].private_ip_address]
}

# Microsoft Purview (optional)
resource "azurerm_purview_account" "main" {
  count               = var.enable_purview ? 1 : 0
  name                = "${var.name_prefix}-purview-${var.name_suffix}"
  resource_group_name = var.resource_group_name
  location            = var.primary_region
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }
}
