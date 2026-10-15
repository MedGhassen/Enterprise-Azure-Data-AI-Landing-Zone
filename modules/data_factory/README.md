# Data Factory module

Azure Data Factory with managed VNet, no public access, private endpoints (dataFactory + portal), managed private endpoints to the data lake, optional GitHub/Azure DevOps Git integration and lake RBAC for its managed identity.

> Managed private endpoints must be approved on the storage account after the first deployment.

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
| [azurerm_data_factory.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory) | resource |
| [azurerm_data_factory_managed_private_endpoint.lake](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory_managed_private_endpoint) | resource |
| [azurerm_monitor_diagnostic_setting.adf](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.adf](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.lake](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| location | Azure region. | `string` | n/a | yes |
| log\_analytics\_workspace\_id | Log Analytics workspace ID for diagnostics. | `string` | n/a | yes |
| name\_prefix | Prefix for resource names, e.g. `dataai-dev-weu`. | `string` | n/a | yes |
| name\_suffix | Instance suffix for resource names, e.g. `001`. | `string` | n/a | yes |
| private\_dns\_zone\_ids | Private DNS zone IDs keyed by zone name (from the networking module). | `map(string)` | n/a | yes |
| private\_endpoint\_subnet\_id | Subnet for the ADF private endpoints. | `string` | n/a | yes |
| resource\_group\_name | Resource group for Data Factory. | `string` | n/a | yes |
| storage\_account\_id | Data lake storage account ID (managed private endpoints + RBAC). | `string` | n/a | yes |
| tenant\_id | Entra tenant ID (Azure DevOps Git integration). | `string` | n/a | yes |
| unique\_suffix | Short random suffix used for globally unique names. | `string` | n/a | yes |
| git\_branch | Collaboration branch. | `string` | `"main"` | no |
| git\_repo\_type | Git integration type: GitHub or AzureDevOpsGit. | `string` | `"GitHub"` | no |
| git\_repo\_url | Git repository URL (https://github.com/<owner>/<repo> or https://dev.azure.com/<org>/<project>/\_git/<repo>). null disables Git integration. | `string` | `null` | no |
| git\_root\_folder | Root folder in the repository. | `string` | `"/"` | no |
| tags | Tags applied to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| data\_factory\_id | Data Factory ID. |
| data\_factory\_name | Data Factory name. |
| principal\_id | Data Factory managed identity principal ID. |
<!-- END_TF_DOCS -->
