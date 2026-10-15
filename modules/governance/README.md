<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.9.0 |
| azurerm | >= 4.40, < 5.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_management_group.connectivity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) | resource |
| [azurerm_management_group.data_ai](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) | resource |
| [azurerm_management_group.identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) | resource |
| [azurerm_management_group.landing_zones](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) | resource |
| [azurerm_management_group.management](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) | resource |
| [azurerm_management_group.platform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) | resource |
| [azurerm_management_group.sandbox](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) | resource |
| [azurerm_management_group_policy_assignment.allowed_locations](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_assignment) | resource |
| [azurerm_management_group_policy_assignment.compliance](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_assignment) | resource |
| [azurerm_management_group_policy_assignment.inherit_rg_tag](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_assignment) | resource |
| [azurerm_management_group_policy_assignment.require_rg_tag](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_assignment) | resource |
| [azurerm_management_group_subscription_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_subscription_association) | resource |
| [azurerm_role_assignment.inherit_rg_tag](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.custom](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_policy_definition.allowed_locations](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_policy_definition.inherit_rg_tag](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_policy_definition.require_rg_tag](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_policy_set_definition.iso27001](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_set_definition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| allowed\_locations | Regions allowed under Landing Zones. | `list(string)` | n/a | yes |
| management\_group\_prefix | Prefix for management group IDs (names), e.g. `contoso` -> `contoso-platform`. | `string` | n/a | yes |
| policy\_identity\_location | Region for the managed identities of policy assignments. | `string` | n/a | yes |
| compliance\_policy\_assignments | Additional initiatives to assign. | ```list(object({ enable = bool assignment_name = string policy_set_definition_id = string display_name = optional(string) assignment_scope = optional(string, "landing_zones") parameters = optional(string) }))``` | `[]` | no |
| compliance\_policy\_parameters\_iso27001 | Parameters (JSON) for the ISO 27001 assignment. | `string` | `null` | no |
| compliance\_policy\_parameters\_nis2 | Parameters (JSON) for the NIS2 assignment. | `string` | `null` | no |
| compliance\_policy\_scope | Management group key for compliance assignments (landing\_zones, platform, sandbox, ...). | `string` | `"landing_zones"` | no |
| create\_default\_custom\_roles | Create Data Engineer, Data Scientist and ML Engineer custom roles at the Landing Zones scope. | `bool` | `true` | no |
| create\_identity\_management\_group | Create the Platform/Identity management group. | `bool` | `false` | no |
| custom\_role\_name\_prefix | Prefix for default custom role names. | `string` | `"Data & AI"` | no |
| custom\_roles | Additional custom roles (defined and assignable at the Landing Zones scope). | ```list(object({ name = string description = string actions = list(string) not_actions = optional(list(string), []) data_actions = optional(list(string), []) }))``` | `[]` | no |
| enable\_iso27001 | Assign the built-in ISO 27001:2013 regulatory compliance initiative. | `bool` | `false` | no |
| enable\_nis2 | Assign a NIS2 initiative (requires nis2\_initiative\_id). | `bool` | `false` | no |
| management\_group\_parent\_id | Parent management group ID. null = tenant root group. | `string` | `null` | no |
| nis2\_initiative\_id | Policy set definition ID of a custom/partner NIS2 initiative. | `string` | `null` | no |
| required\_tags | Tags required on resource groups and inherited by resources. | `list(string)` | ```[ "environment", "cost_center", "owner" ]``` | no |
| role\_assignments | Role assignments. role: built-in role name or custom role name; scope: management group key (e.g. dataai\_prod) or a full resource ID. | ```list(object({ principal_id = string role = string scope = string }))``` | `[]` | no |
| subscription\_placement | Subscriptions to move under management groups. Keys: platform, landing\_zones, sandbox, management, connectivity, identity, dataai\_dev, dataai\_staging, dataai\_prod. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| custom\_role\_definition\_ids | Custom role definition resource IDs keyed by role name. |
| management\_group\_ids | Management group IDs keyed by role (platform, landing\_zones, sandbox, management, connectivity, identity, dataai\_dev, dataai\_staging, dataai\_prod). |
| policy\_assignment\_ids | Policy assignment IDs keyed by assignment name. |
<!-- END_TF_DOCS -->