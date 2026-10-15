# AI module

Microsoft Foundry (AI Services account with project management, Foundry projects and model deployments), Azure AI Search and an optional Azure Machine Learning workspace. Everything is private and keyless: local auth is disabled and services talk to each other with managed identities (Foundry <-> AI Search connection and RBAC).

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
| [azurerm_cognitive_account.foundry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) | resource |
| [azurerm_cognitive_account_connection_entra_id.search](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account_connection_entra_id) | resource |
| [azurerm_cognitive_account_project.projects](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account_project) | resource |
| [azurerm_cognitive_deployment.models](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_deployment) | resource |
| [azurerm_machine_learning_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/machine_learning_workspace) | resource |
| [azurerm_monitor_diagnostic_setting.foundry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.ml](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.search](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.foundry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.ml](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.ml_storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.search](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.foundry_search](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.search_foundry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_search_service.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/search_service) | resource |
| [azurerm_storage_account.ml](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| application\_insights\_id | Application Insights ID used by the ML workspace. | `string` | n/a | yes |
| key\_vault\_id | Key Vault ID used by the ML workspace. | `string` | n/a | yes |
| location | Azure region. | `string` | n/a | yes |
| log\_analytics\_workspace\_id | Log Analytics workspace ID for diagnostics. | `string` | n/a | yes |
| name\_prefix | Prefix for resource names, e.g. `dataai-dev-weu`. | `string` | n/a | yes |
| name\_suffix | Instance suffix for resource names, e.g. `001`. | `string` | n/a | yes |
| private\_dns\_zone\_ids | Private DNS zone IDs keyed by zone name (from the networking module). | `map(string)` | n/a | yes |
| private\_endpoint\_subnet\_id | Subnet for AI private endpoints (snet-ai). | `string` | n/a | yes |
| resource\_group\_name | Resource group for AI resources. | `string` | n/a | yes |
| unique\_suffix | Short random suffix used for globally unique names. | `string` | n/a | yes |
| container\_registry\_id | Private Premium ACR for ML images (recommended for private workspaces). null lets Azure ML create one on demand. | `string` | `null` | no |
| enable\_foundry | Deploy a Microsoft Foundry (AI Services) account with projects and model deployments. | `bool` | `true` | no |
| enable\_ml\_workspace | Deploy an Azure Machine Learning workspace. | `bool` | `true` | no |
| enable\_search | Deploy Azure AI Search. | `bool` | `true` | no |
| foundry\_projects | Foundry projects to create. | ```list(object({ name = string display_name = optional(string) description = optional(string) }))``` | ```[ { "display_name": "Main project", "name": "main" } ]``` | no |
| ml\_isolation\_mode | Managed network isolation: AllowInternetOutbound or AllowOnlyApprovedOutbound. | `string` | `"AllowInternetOutbound"` | no |
| model\_deployments | Model deployments on the Foundry account. Check regional availability and retirement dates before changing: https://learn.microsoft.com/azure/ai-foundry/openai/concepts/models | ```list(object({ name = string model = string version = string format = optional(string, "OpenAI") sku_name = optional(string, "GlobalStandard") capacity = optional(number, 10) }))``` | ```[ { "capacity": 10, "model": "gpt-4.1-mini", "name": "gpt-4.1-mini", "version": "2025-04-14" }, { "capacity": 10, "model": "text-embedding-3-large", "name": "text-embedding-3-large", "sku_name": "Standard", "version": "1" } ]``` | no |
| search\_partition\_count | AI Search partitions. | `number` | `1` | no |
| search\_replica\_count | AI Search replicas (2+ for read SLA, 3+ for read/write SLA). | `number` | `1` | no |
| search\_semantic\_sku | Semantic ranker plan (free or standard), null to disable. | `string` | `"free"` | no |
| search\_sku | AI Search SKU (basic, standard, standard2, standard3, storage\_optimized\_l1/l2). Private endpoints need basic or higher. | `string` | `"standard"` | no |
| tags | Tags applied to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| foundry\_account\_id | Foundry (AI Services) account ID (null when disabled). |
| foundry\_endpoint | Foundry (AI Services) endpoint (null when disabled). |
| foundry\_project\_ids | Foundry project IDs keyed by name. |
| ml\_workspace\_id | Azure ML workspace ID (null when disabled). |
| model\_deployment\_names | Model deployment names. |
| search\_endpoint | AI Search endpoint (null when disabled). |
| search\_service\_id | AI Search service ID (null when disabled). |
<!-- END_TF_DOCS -->
