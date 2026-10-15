# Streaming module

Event Hubs namespace (Entra-only, private endpoint, TLS 1.2) with event hubs, and an optional Stream Analytics job with a managed identity that can read from Event Hubs.

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
| [azurerm_eventhub.hubs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub) | resource |
| [azurerm_eventhub_namespace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace) | resource |
| [azurerm_monitor_diagnostic_setting.asa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.eventhubs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.eventhubs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.asa_eventhubs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_stream_analytics_job.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/stream_analytics_job) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| location | Azure region. | `string` | n/a | yes |
| log\_analytics\_workspace\_id | Log Analytics workspace ID for diagnostics. | `string` | n/a | yes |
| name\_prefix | Prefix for resource names, e.g. `dataai-dev-weu`. | `string` | n/a | yes |
| name\_suffix | Instance suffix for resource names, e.g. `001`. | `string` | n/a | yes |
| private\_dns\_zone\_ids | Private DNS zone IDs keyed by zone name (from the networking module). | `map(string)` | n/a | yes |
| private\_endpoint\_subnet\_id | Subnet for the Event Hubs private endpoint. | `string` | n/a | yes |
| resource\_group\_name | Resource group for streaming resources. | `string` | n/a | yes |
| unique\_suffix | Short random suffix used for globally unique names. | `string` | n/a | yes |
| enable\_stream\_analytics | Create a Stream Analytics job. | `bool` | `false` | no |
| event\_hubs | Event hubs to create. | ```list(object({ name = string partition_count = optional(number, 4) message_retention = optional(number, 7) }))``` | ```[ { "name": "ingest" } ]``` | no |
| event\_hubs\_capacity | Throughput units (Standard) or processing units (Premium). | `number` | `1` | no |
| event\_hubs\_max\_throughput\_units | Auto-inflate maximum throughput units (Standard only, 0 disables auto-inflate). | `number` | `0` | no |
| event\_hubs\_sku | Event Hubs namespace SKU. Standard or Premium (private endpoints are not available on Basic). | `string` | `"Standard"` | no |
| stream\_analytics\_query | Stream Analytics transformation query. Inputs/outputs must be defined separately. | `string` | `"SELECT * INTO [output] FROM [input]"` | no |
| stream\_analytics\_streaming\_units | Streaming units for the Stream Analytics job. | `number` | `3` | no |
| tags | Tags applied to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| event\_hubs\_namespace\_id | Event Hubs namespace ID. |
| event\_hubs\_namespace\_name | Event Hubs namespace name. |
| stream\_analytics\_job\_id | Stream Analytics job ID (null when disabled). |
<!-- END_TF_DOCS -->
