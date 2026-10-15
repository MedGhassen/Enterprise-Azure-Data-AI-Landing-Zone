# Security module

Key Vault (RBAC only, private endpoint, purge protection, audit logs) and, optionally, Microsoft Defender for Cloud plans and the security contact. Defender settings are subscription-wide: enable them in only one stack per subscription.

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
| [azurerm_key_vault.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_monitor_diagnostic_setting.kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_security_center_contact.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_contact) | resource |
| [azurerm_security_center_subscription_pricing.plans](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_subscription_pricing) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| location | Azure region. | `string` | n/a | yes |
| log\_analytics\_workspace\_id | Log Analytics workspace ID for diagnostics. | `string` | n/a | yes |
| name\_prefix | Prefix for resource names, e.g. `dataai-dev-weu`. | `string` | n/a | yes |
| name\_suffix | Instance suffix for resource names, e.g. `001`. | `string` | n/a | yes |
| private\_dns\_zone\_ids | Private DNS zone IDs keyed by zone name (from the networking module). | `map(string)` | n/a | yes |
| private\_endpoint\_subnet\_id | Subnet for the Key Vault private endpoint. | `string` | n/a | yes |
| resource\_group\_name | Resource group for security resources. | `string` | n/a | yes |
| unique\_suffix | Short random suffix used for globally unique names. | `string` | n/a | yes |
| defender\_contact\_email | Security contact email for Defender alerts. | `string` | `null` | no |
| defender\_contact\_phone | Optional security contact phone number. | `string` | `null` | no |
| defender\_plans | Defender for Cloud plans to enable (resource types). | `list(string)` | ```[ "StorageAccounts", "SqlServers", "KeyVaults", "Containers", "Arm", "CosmosDbs", "AI" ]``` | no |
| enable\_defender | Manage Defender for Cloud plans and security contact for the current subscription. | `bool` | `false` | no |
| key\_vault\_sku | Key Vault SKU (standard or premium). | `string` | `"premium"` | no |
| purge\_protection\_enabled | Enable purge protection. Recommended for prod; once enabled it cannot be disabled. | `bool` | `true` | no |
| soft\_delete\_retention\_days | Soft-delete retention (7-90 days). | `number` | `90` | no |
| tags | Tags applied to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| key\_vault\_id | Key Vault ID. |
| key\_vault\_name | Key Vault name. |
| key\_vault\_uri | Key Vault URI. |
<!-- END_TF_DOCS -->
