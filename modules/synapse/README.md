# Synapse module

Synapse workspace with Entra-only authentication, managed VNet, no public access, private endpoints for Sql/SqlOnDemand/Dev, a Private Link Hub for Studio, an auto-pausing Spark pool and an optional dedicated SQL pool.

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
| [azurerm_monitor_diagnostic_setting.synapse](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.synapse](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.web](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.lake](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_synapse_private_link_hub.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_private_link_hub) | resource |
| [azurerm_synapse_spark_pool.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_spark_pool) | resource |
| [azurerm_synapse_sql_pool.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_sql_pool) | resource |
| [azurerm_synapse_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace) | resource |
| [azurerm_synapse_workspace_aad_admin.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace_aad_admin) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| data\_lake\_filesystem\_id | Primary ADLS Gen2 filesystem URL, e.g. https://<account>.dfs.core.windows.net/synapse. | `string` | n/a | yes |
| entra\_admin\_object\_id | Object ID of the Entra user/group that is Synapse SQL administrator. | `string` | n/a | yes |
| location | Azure region. | `string` | n/a | yes |
| log\_analytics\_workspace\_id | Log Analytics workspace ID for diagnostics. | `string` | n/a | yes |
| name\_prefix | Prefix for resource names, e.g. `dataai-dev-weu`. | `string` | n/a | yes |
| name\_suffix | Instance suffix for resource names, e.g. `001`. | `string` | n/a | yes |
| private\_dns\_zone\_ids | Private DNS zone IDs keyed by zone name (from the networking module). | `map(string)` | n/a | yes |
| private\_endpoint\_subnet\_id | Subnet for the Synapse private endpoints. | `string` | n/a | yes |
| resource\_group\_name | Resource group for Synapse. | `string` | n/a | yes |
| storage\_account\_id | Data lake storage account ID (RBAC for the workspace identity). | `string` | n/a | yes |
| tenant\_id | Entra tenant ID. | `string` | n/a | yes |
| unique\_suffix | Short random suffix used for globally unique names. | `string` | n/a | yes |
| data\_exfiltration\_protection\_enabled | Restrict managed VNet outbound traffic to approved targets (cannot be changed after creation). | `bool` | `false` | no |
| enable\_sql\_pool | Create a dedicated SQL pool (billed while running). | `bool` | `false` | no |
| entra\_admin\_login | Display name of the Entra SQL administrator. | `string` | `"sql-entra-admin"` | no |
| spark\_auto\_pause\_minutes | Idle minutes before the Spark pool pauses. | `number` | `15` | no |
| spark\_max\_nodes | Maximum Spark nodes. | `number` | `10` | no |
| spark\_min\_nodes | Minimum Spark nodes. | `number` | `3` | no |
| spark\_node\_size | Spark node size (Small, Medium, Large, ...). | `string` | `"Small"` | no |
| spark\_version | Spark runtime version. | `string` | `"3.4"` | no |
| sql\_pool\_sku | Dedicated SQL pool SKU. | `string` | `"DW100c"` | no |
| tags | Tags applied to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| connectivity\_endpoints | Synapse endpoints (dev, sql, sqlOnDemand, web). |
| principal\_id | Synapse workspace managed identity principal ID. |
| workspace\_id | Synapse workspace ID. |
| workspace\_name | Synapse workspace name. |
<!-- END_TF_DOCS -->
