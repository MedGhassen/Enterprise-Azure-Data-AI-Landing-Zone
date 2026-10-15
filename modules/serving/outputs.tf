output "container_registry_id" {
  description = "ACR ID."
  value       = azurerm_container_registry.main.id
}

output "acr_login_server" {
  description = "ACR login server."
  value       = azurerm_container_registry.main.login_server
}

output "aks_id" {
  description = "AKS cluster ID (null when disabled)."
  value       = try(azurerm_kubernetes_cluster.main[0].id, null)
}

output "aks_private_fqdn" {
  description = "AKS API server private FQDN (null when disabled)."
  value       = try(azurerm_kubernetes_cluster.main[0].private_fqdn, null)
}

output "aks_oidc_issuer_url" {
  description = "AKS OIDC issuer URL for workload identity federation (null when disabled)."
  value       = try(azurerm_kubernetes_cluster.main[0].oidc_issuer_url, null)
}

output "purview_account_id" {
  description = "Purview account ID (null when disabled)."
  value       = try(azurerm_purview_account.main[0].id, null)
}

output "aks_outbound_type" {
  description = "AKS egress mode: userDefinedRouting (via firewall) or loadBalancer (null when disabled)."
  value       = try(azurerm_kubernetes_cluster.main[0].network_profile[0].outbound_type, null)
}
