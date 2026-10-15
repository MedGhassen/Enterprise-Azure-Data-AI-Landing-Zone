# Data lake module

ADLS Gen2 account with Entra-only access (shared keys disabled), no public network access, blob/dfs private endpoints, medallion filesystems created through the control plane, lifecycle tiering and diagnostics.

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
| [azurerm_monitor_diagnostic_setting.blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_storage_account.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.filesystems](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_management_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| location | Azure region. | `string` | n/a | yes |
| log\_analytics\_workspace\_id | Log Analytics workspace ID for diagnostics. | `string` | n/a | yes |
| name\_prefix | Prefix for resource names, e.g. `dataai-dev-weu`. | `string` | n/a | yes |
| name\_suffix | Instance suffix for resource names, e.g. `001`. | `string` | n/a | yes |
| private\_dns\_zone\_ids | Private DNS zone IDs keyed by zone name (from the networking module). | `map(string)` | n/a | yes |
| private\_endpoint\_subnet\_id | Subnet for the blob/dfs private endpoints. | `string` | n/a | yes |
| resource\_group\_name | Resource group for the data lake. | `string` | n/a | yes |
| unique\_suffix | Short random suffix used for globally unique names. | `string` | n/a | yes |
| blob\_soft\_delete\_retention\_days | Blob soft-delete retention in days. | `number` | `30` | no |
| container\_soft\_delete\_retention\_days | Container soft-delete retention in days. | `number` | `30` | no |
| filesystems | ADLS Gen2 filesystems (containers) to create. Medallion layers plus Unity Catalog and Synapse workspace storage. | `list(string)` | ```[ "raw", "curated", "enriched", "unity", "synapse" ]``` | no |
| lifecycle\_archive\_after\_days | Days after last modification before raw blobs move to Archive. | `number` | `365` | no |
| lifecycle\_cool\_after\_days | Days after last modification before raw blobs move to Cool. | `number` | `90` | no |
| replication | Replication type (LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS). | `string` | `"ZRS"` | no |
| tags | Tags applied to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| dfs\_endpoint | ADLS Gen2 DFS endpoint. |
| filesystems | Created filesystems keyed by name (value: container ID). |
| storage\_account\_id | ADLS Gen2 storage account ID. |
| storage\_account\_name | ADLS Gen2 storage account name. |
<!-- END_TF_DOCS -->
