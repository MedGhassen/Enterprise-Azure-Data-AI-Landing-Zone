# Databases module

Azure SQL (Entra-only auth, private endpoint, server auditing to Log Analytics) and Cosmos DB for NoSQL (local auth disabled, private endpoint, continuous backup, serverless or autoscale). Each is optional.

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
| [azurerm_cosmosdb_account.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account) | resource |
| [azurerm_cosmosdb_sql_container.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_container) | resource |
| [azurerm_cosmosdb_sql_database.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_database) | resource |
| [azurerm_monitor_diagnostic_setting.cosmos](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.sql_audit](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.sql_db](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_mssql_database.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_server.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) | resource |
| [azurerm_mssql_server_extended_auditing_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_extended_auditing_policy) | resource |
| [azurerm_private_endpoint.cosmos](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.sql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| entra\_admin\_object\_id | Object ID of the Entra user/group that administers the SQL server. | `string` | n/a | yes |
| location | Azure region. | `string` | n/a | yes |
| log\_analytics\_workspace\_id | Log Analytics workspace ID for diagnostics and auditing. | `string` | n/a | yes |
| name\_prefix | Prefix for resource names, e.g. `dataai-dev-weu`. | `string` | n/a | yes |
| name\_suffix | Instance suffix for resource names, e.g. `001`. | `string` | n/a | yes |
| private\_dns\_zone\_ids | Private DNS zone IDs keyed by zone name (from the networking module). | `map(string)` | n/a | yes |
| private\_endpoint\_subnet\_id | Subnet for the database private endpoints. | `string` | n/a | yes |
| resource\_group\_name | Resource group for databases. | `string` | n/a | yes |
| tenant\_id | Entra tenant ID. | `string` | n/a | yes |
| unique\_suffix | Short random suffix used for globally unique names. | `string` | n/a | yes |
| cosmos\_autoscale\_max\_throughput | Autoscale max RU/s for the default container (provisioned mode). | `number` | `1000` | no |
| cosmos\_consistency\_level | Cosmos DB consistency level. | `string` | `"Session"` | no |
| cosmos\_failover\_locations | Additional regions for geo-replication, in failover priority order. | `list(string)` | `[]` | no |
| cosmos\_serverless | Use serverless capacity mode (no failover regions, no autoscale). | `bool` | `false` | no |
| cosmos\_zone\_redundant | Zone redundancy for the primary region. | `bool` | `false` | no |
| enable\_cosmos | Deploy Cosmos DB (NoSQL). | `bool` | `true` | no |
| enable\_sql | Deploy Azure SQL server + database. | `bool` | `true` | no |
| entra\_admin\_login | Display name of the Entra SQL administrator. | `string` | `"sql-entra-admin"` | no |
| sql\_database\_sku | Azure SQL database SKU (e.g. GP\_S\_Gen5\_1 serverless, S0, GP\_Gen5\_2). | `string` | `"GP_S_Gen5_1"` | no |
| tags | Tags applied to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| cosmos\_db\_endpoint | Cosmos DB endpoint (null when disabled). |
| cosmos\_db\_id | Cosmos DB account ID (null when disabled). |
| sql\_server\_fqdn | Azure SQL server FQDN (null when disabled). |
| sql\_server\_id | Azure SQL server ID (null when disabled). |
<!-- END_TF_DOCS -->
