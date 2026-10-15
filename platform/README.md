# Platform stack (tenant-level governance)

Deploy this stack **once per tenant**, before the per-environment landing zones in the repository root.
It manages the management group hierarchy, subscription placement, baseline policies, regulatory
compliance initiatives and the Data & AI custom roles (see [`modules/governance`](../modules/governance)).

```bash
cd platform
cp platform.tfvars.example platform.tfvars   # git-ignored; edit it
terraform init \
  -backend-config="resource_group_name=rg-terraform-state" \
  -backend-config="storage_account_name=<from bootstrap>" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=platform.tfstate"
terraform plan  -var-file=platform.tfvars
terraform apply -var-file=platform.tfvars
```

Required permissions: **Management Group Contributor** and **Resource Policy Contributor** (or Owner) at the
parent management group, plus **User Access Administrator** for the policy identities and role assignments.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.9.0 |
| azurerm | ~> 4.40 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| management\_group\_prefix | Prefix for management group IDs, e.g. `contoso` -> `contoso-platform`. | `string` | n/a | yes |
| allowed\_locations | Regions allowed under Landing Zones. | `list(string)` | ```[ "westeurope", "northeurope" ]``` | no |
| compliance\_policy\_assignments | Additional initiatives to assign (see modules/governance). | ```list(object({ enable = bool assignment_name = string policy_set_definition_id = string display_name = optional(string) assignment_scope = optional(string, "landing_zones") parameters = optional(string) }))``` | `[]` | no |
| compliance\_policy\_scope | Management group key for compliance assignments. | `string` | `"landing_zones"` | no |
| create\_default\_custom\_roles | Create Data Engineer, Data Scientist and ML Engineer custom roles. | `bool` | `true` | no |
| create\_identity\_management\_group | Create the Platform/Identity management group. | `bool` | `false` | no |
| enable\_iso27001 | Assign the ISO 27001:2013 regulatory compliance initiative. | `bool` | `false` | no |
| enable\_nis2 | Assign a NIS2 initiative (requires nis2\_initiative\_id). | `bool` | `false` | no |
| management\_group\_parent\_id | Parent management group ID. null = tenant root group. | `string` | `null` | no |
| nis2\_initiative\_id | Policy set definition ID of a custom/partner NIS2 initiative. | `string` | `null` | no |
| policy\_identity\_location | Region for policy assignment managed identities. | `string` | `"westeurope"` | no |
| required\_tags | Tags required on resource groups and inherited by resources. | `list(string)` | ```[ "environment", "cost_center", "owner" ]``` | no |
| role\_assignments | Role assignments (role name or custom role name; scope = management group key or resource ID). | ```list(object({ principal_id = string role = string scope = string }))``` | `[]` | no |
| subscription\_id | Subscription used for API calls. null uses ARM\_SUBSCRIPTION\_ID / the Azure CLI context. | `string` | `null` | no |
| subscription\_placement | Subscriptions to place under management groups. Keys: platform, landing\_zones, sandbox, management, connectivity, identity, dataai\_dev, dataai\_staging, dataai\_prod. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| custom\_role\_definition\_ids | Custom role definition IDs keyed by name. |
| management\_group\_ids | Management group IDs keyed by role. |
| policy\_assignment\_ids | Policy assignment IDs keyed by name. |
<!-- END_TF_DOCS -->
