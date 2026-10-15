output "aks_id" {
  description = "AKS cluster resource ID"
  value       = azurerm_kubernetes_cluster.main.id
}

output "aks_fqdn" {
  description = "AKS private FQDN (use from VNet)"
  value       = azurerm_kubernetes_cluster.main.private_fqdn
}

output "aks_kubeconfig" {
  description = "AKS kubeconfig (sensitive)"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "acr_login_server" {
  description = "ACR login server"
  value       = azurerm_container_registry.main.login_server
}

output "acr_id" {
  description = "ACR resource ID"
  value       = azurerm_container_registry.main.id
}

output "purview_account_id" {
  description = "Purview account ID (if enabled)"
  value       = try(azurerm_purview_account.main[0].id, null)
}

output "purview_endpoints" {
  description = "Purview endpoints (if enabled)"
  value       = try(azurerm_purview_account.main[0].catalog_endpoint, null)
}
