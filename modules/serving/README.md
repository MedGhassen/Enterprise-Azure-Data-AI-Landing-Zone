# Serving module

Premium Azure Container Registry with a private endpoint; a private AKS cluster (Entra ID + Azure RBAC, local accounts disabled, CNI Overlay with Cilium, workload identity, auto-upgrades, optional egress through the hub firewall); and optional Microsoft Purview with private endpoints and read access to the lake.

Used by the root landing zone stack; see the [main README](../../README.md) for the architecture.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.9.0 |
| azurerm | >= 4.40, < 5.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_container_registry.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) | resource |
| [azurerm_kubernetes_cluster.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_monitor_diagnostic_setting.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.purview](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_purview_account.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/purview_account) | resource |
| [azurerm_role_assignment.aks_acr_pull](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_deployer_admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_kubelet_operator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_route_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.purview_lake](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.kubelet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| aks\_subnet\_id | Subnet for AKS nodes (snet-serving). | `string` | n/a | yes |
| location | Azure region. | `string` | n/a | yes |
| log\_analytics\_workspace\_id | Log Analytics workspace ID for diagnostics and Container Insights. | `string` | n/a | yes |
| name\_prefix | Prefix for resource names, e.g. `dataai-dev-weu`. | `string` | n/a | yes |
| name\_suffix | Instance suffix for resource names, e.g. `001`. | `string` | n/a | yes |
| private\_dns\_zone\_ids | Private DNS zone IDs keyed by zone name (from the networking module). | `map(string)` | n/a | yes |
| private\_endpoint\_subnet\_id | Subnet for ACR/Purview private endpoints. | `string` | n/a | yes |
| resource\_group\_name | Resource group for serving resources. | `string` | n/a | yes |
| storage\_account\_id | Data lake storage account ID (Purview scanning). | `string` | n/a | yes |
| unique\_suffix | Short random suffix used for globally unique names. | `string` | n/a | yes |
| acr\_zone\_redundancy\_enabled | Zone-redundant ACR (cannot be changed after creation). | `bool` | `true` | no |
| aks\_admin\_group\_object\_ids | Entra group object IDs with cluster-admin rights. | `list(string)` | `[]` | no |
| aks\_pod\_cidr | Pod CIDR for CNI Overlay (must not overlap the VNets). | `string` | `"192.168.0.0/16"` | no |
| aks\_service\_cidr | Kubernetes service CIDR (must not overlap the VNets). | `string` | `"172.17.0.0/16"` | no |
| aks\_sku\_tier | AKS control plane tier: Free (dev) or Standard (SLA). | `string` | `"Standard"` | no |
| availability\_zones | Availability zones for AKS node pools. Use null in regions without zones. | `list(string)` | ```[ "1", "2", "3" ]``` | no |
| egress\_via\_firewall | Use userDefinedRouting egress through the hub firewall (requires route\_table\_id). | `bool` | `false` | no |
| enable\_aks | Deploy the AKS cluster. | `bool` | `true` | no |
| enable\_purview | Deploy Microsoft Purview. | `bool` | `false` | no |
| grant\_deployer\_cluster\_admin | Grant the deploying principal 'Azure Kubernetes Service RBAC Cluster Admin'. | `bool` | `false` | no |
| kubernetes\_version | Kubernetes version (null = AKS default). Patch upgrades are automatic. | `string` | `null` | no |
| route\_table\_id | Route table attached to the AKS subnet (required when egress\_via\_firewall = true). | `string` | `null` | no |
| system\_node\_max\_count | Maximum system nodes. | `number` | `3` | no |
| system\_node\_min\_count | Minimum system nodes. | `number` | `2` | no |
| system\_node\_vm\_size | VM size for the system node pool. | `string` | `"Standard_D4ds_v5"` | no |
| tags | Tags applied to all resources. | `map(string)` | `{}` | no |
| user\_node\_max\_count | Maximum user nodes. | `number` | `5` | no |
| user\_node\_min\_count | Minimum user nodes. | `number` | `1` | no |
| user\_node\_vm\_size | VM size for the user node pool. | `string` | `"Standard_D4ds_v5"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| acr\_login\_server | ACR login server. |
| aks\_id | AKS cluster ID (null when disabled). |
| aks\_oidc\_issuer\_url | AKS OIDC issuer URL for workload identity federation (null when disabled). |
| aks\_outbound\_type | AKS egress mode: userDefinedRouting (via firewall) or loadBalancer (null when disabled). |
| aks\_private\_fqdn | AKS API server private FQDN (null when disabled). |
| container\_registry\_id | ACR ID. |
| purview\_account\_id | Purview account ID (null when disabled). |
<!-- END_TF_DOCS -->
