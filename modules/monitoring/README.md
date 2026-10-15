# Monitoring module

Log Analytics workspace, workspace-based Application Insights, an action group (email/webhook) and a Service Health alert.

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
| [azurerm_application_insights.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_log_analytics_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_action_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) | resource |
| [azurerm_monitor_activity_log_alert.service_health](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_activity_log_alert) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| location | Azure region. | `string` | n/a | yes |
| location\_display\_name | Display name of the region used by Service Health alerts, e.g. `West Europe`. | `string` | n/a | yes |
| name\_prefix | Prefix for resource names, e.g. `dataai-dev-weu`. | `string` | n/a | yes |
| name\_suffix | Instance suffix for resource names, e.g. `001`. | `string` | n/a | yes |
| resource\_group\_name | Resource group for monitoring resources. | `string` | n/a | yes |
| action\_group\_emails | Email addresses notified by the action group. | `list(string)` | `[]` | no |
| action\_group\_webhook\_url | Optional webhook (e.g. Teams/Slack) for the action group. | `string` | `null` | no |
| daily\_quota\_gb | Daily ingestion cap in GB (-1 = unlimited). Useful to cap dev costs. | `number` | `-1` | no |
| log\_retention\_days | Log Analytics retention in days (30-730). | `number` | `90` | no |
| tags | Tags applied to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| action\_group\_id | Action group ID for alerts. |
| application\_insights\_id | Application Insights resource ID. |
| log\_analytics\_workspace\_guid | Log Analytics workspace (customer) ID. |
| log\_analytics\_workspace\_id | Log Analytics workspace resource ID. |
<!-- END_TF_DOCS -->
