# Databricks module

Premium Azure Databricks workspace with VNet injection, secure cluster connectivity (no public IP), front-end/back-end Private Link and browser-authentication endpoint, plus an Access Connector with lake access for Unity Catalog.

> The Unity Catalog metastore and storage credential are account-level objects: create them in the Databricks account console (or with the databricks provider) using the Access Connector output.

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
| [azurerm_databricks_access_connector.unity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_access_connector) | resource |
| [azurerm_databricks_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_workspace) | resource |
| [azurerm_monitor_diagnostic_setting.dbw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.browser_auth](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.ui_api](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.unity_lake](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| location | Azure region. | `string` | n/a | yes |
| log\_analytics\_workspace\_id | Log Analytics workspace ID for diagnostics. | `string` | n/a | yes |
| name\_prefix | Prefix for resource names, e.g. `dataai-dev-weu`. | `string` | n/a | yes |
| name\_suffix | Instance suffix for resource names, e.g. `001`. | `string` | n/a | yes |
| private\_dns\_zone\_ids | Private DNS zone IDs keyed by zone name (from the networking module). | `map(string)` | n/a | yes |
| private\_endpoint\_subnet\_id | Subnet for the workspace private endpoints. | `string` | n/a | yes |
| private\_subnet\_name | Name of the delegated private (container) subnet. | `string` | n/a | yes |
| private\_subnet\_nsg\_association\_id | NSG association ID of the private subnet. | `string` | n/a | yes |
| public\_subnet\_name | Name of the delegated public (host) subnet. | `string` | n/a | yes |
| public\_subnet\_nsg\_association\_id | NSG association ID of the public subnet. | `string` | n/a | yes |
| resource\_group\_name | Resource group for Databricks. | `string` | n/a | yes |
| storage\_account\_id | Data lake storage account ID (Unity Catalog access connector RBAC). | `string` | n/a | yes |
| virtual\_network\_id | Spoke VNet ID used for VNet injection. | `string` | n/a | yes |
| create\_browser\_authentication\_endpoint | Create the browser\_authentication private endpoint (one per region is enough). | `bool` | `true` | no |
| public\_network\_access\_enabled | Allow access to the workspace UI/API from the internet. Keep false for a fully private workspace. | `bool` | `false` | no |
| tags | Tags applied to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| access\_connector\_id | Access Connector ID for the Unity Catalog storage credential. |
| workspace\_id | Databricks workspace resource ID. |
| workspace\_url | Databricks workspace URL. |
<!-- END_TF_DOCS -->
