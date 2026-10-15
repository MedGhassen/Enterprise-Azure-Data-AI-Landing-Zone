# Shared mock data for `terraform test` (offline). Provides syntactically valid
# Azure resource IDs so provider-side argument validation passes.

mock_data "azurerm_client_config" {
  defaults = {
    tenant_id       = "00000000-0000-0000-0000-000000000001"
    object_id       = "00000000-0000-0000-0000-000000000002"
    client_id       = "00000000-0000-0000-0000-000000000003"
    subscription_id = "00000000-0000-0000-0000-000000000004"
  }
}

mock_data "azurerm_subscription" {
  defaults = {
    id              = "/subscriptions/00000000-0000-0000-0000-000000000004"
    subscription_id = "00000000-0000-0000-0000-000000000004"
  }
}

mock_data "azurerm_policy_definition" {
  defaults = {
    id = "/providers/Microsoft.Authorization/policyDefinitions/00000000-0000-0000-0000-000000000040"
  }
}

mock_data "azurerm_policy_set_definition" {
  defaults = {
    id = "/providers/Microsoft.Authorization/policySetDefinitions/00000000-0000-0000-0000-000000000041"
  }
}

mock_resource "azurerm_application_insights" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Insights/components/appi-mock"
  }
}

mock_resource "azurerm_bastion_host" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/bastionHosts/bas-mock"
  }
}

mock_resource "azurerm_cognitive_account" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.CognitiveServices/accounts/aif-mock"
  }
}

mock_resource "azurerm_cognitive_account_project" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.CognitiveServices/accounts/aif-mock/projects/main"
  }
}

mock_resource "azurerm_container_registry" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.ContainerRegistry/registries/crmock"
  }
}

mock_resource "azurerm_cosmosdb_account" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.DocumentDB/databaseAccounts/cosmos-mock"
  }
}

mock_resource "azurerm_cosmosdb_sql_database" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.DocumentDB/databaseAccounts/cosmos-mock/sqlDatabases/db"
  }
}

mock_resource "azurerm_data_factory" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.DataFactory/factories/adf-mock"
  }
}

mock_resource "azurerm_databricks_access_connector" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Databricks/accessConnectors/dbac-mock"
  }
}

mock_resource "azurerm_databricks_workspace" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Databricks/workspaces/dbw-mock"
  }
}

mock_resource "azurerm_eventhub_namespace" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.EventHub/namespaces/evhns-mock"
  }
}

mock_resource "azurerm_firewall" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/azureFirewalls/fw-mock"
  }
}

mock_resource "azurerm_firewall_policy" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/firewallPolicies/fwp-mock"
  }
}

mock_resource "azurerm_firewall_policy_rule_collection_group" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/firewallPolicies/fwp-mock/ruleCollectionGroups/rcg-mock"
  }
}

mock_resource "azurerm_key_vault" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.KeyVault/vaults/kv-mock"
  }
}

mock_resource "azurerm_kubernetes_cluster" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.ContainerService/managedClusters/aks-mock"
  }
}

mock_resource "azurerm_machine_learning_workspace" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.MachineLearningServices/workspaces/mlw-mock"
  }
}

mock_resource "azurerm_management_group" {
  defaults = {
    id = "/providers/Microsoft.Management/managementGroups/mg-mock"
  }
}

mock_resource "azurerm_monitor_action_group" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Insights/actionGroups/ag-mock"
  }
}

mock_resource "azurerm_mssql_database" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Sql/servers/sql-mock/databases/sqldb"
  }
}

mock_resource "azurerm_mssql_server" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Sql/servers/sql-mock"
  }
}

mock_resource "azurerm_nat_gateway" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/natGateways/ng-mock"
  }
}

mock_resource "azurerm_network_security_group" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/networkSecurityGroups/nsg-mock"
  }
}

mock_resource "azurerm_network_watcher" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/networkWatchers/nw-mock"
  }
}

mock_resource "azurerm_private_dns_resolver" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/dnsResolvers/dnspr-mock"
  }
}

mock_resource "azurerm_private_dns_resolver_inbound_endpoint" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/dnsResolvers/dnspr-mock/inboundEndpoints/in-mock"
  }
}

mock_resource "azurerm_private_dns_zone" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/privateDnsZones/privatelink.mock.net"
  }
}

mock_resource "azurerm_private_endpoint" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/privateEndpoints/pe-mock"
  }
}

mock_resource "azurerm_public_ip" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/publicIPAddresses/pip-mock"
  }
}

mock_resource "azurerm_purview_account" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Purview/accounts/pview-mock"
  }
}

mock_resource "azurerm_resource_group" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock"
  }
}

mock_resource "azurerm_route_table" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/routeTables/rt-mock"
  }
}

mock_resource "azurerm_search_service" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Search/searchServices/srch-mock"
  }
}

mock_resource "azurerm_stream_analytics_job" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.StreamAnalytics/streamingJobs/asa-mock"
  }
}

mock_resource "azurerm_subnet" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/virtualNetworks/vnet-mock/subnets/snet-mock"
  }
}

mock_resource "azurerm_subnet_network_security_group_association" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/virtualNetworks/vnet-mock/subnets/snet-mock"
  }
}

mock_resource "azurerm_subnet_route_table_association" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/virtualNetworks/vnet-mock/subnets/snet-mock"
  }
}

mock_resource "azurerm_synapse_private_link_hub" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Synapse/privateLinkHubs/plhmock"
  }
}

mock_resource "azurerm_synapse_workspace" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Synapse/workspaces/syn-mock"
  }
}

mock_resource "azurerm_virtual_network" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/virtualNetworks/vnet-mock"
  }
}

mock_resource "azurerm_virtual_network_gateway" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/virtualNetworkGateways/vpngw-mock"
  }
}

mock_resource "azurerm_log_analytics_workspace" {
  defaults = {
    id           = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.OperationalInsights/workspaces/law-mock"
    workspace_id = "00000000-0000-0000-0000-000000000020"
  }
}

mock_resource "azurerm_role_definition" {
  defaults = {
    id                          = "/providers/Microsoft.Authorization/roleDefinitions/00000000-0000-0000-0000-000000000030|/providers/Microsoft.Management/managementGroups/mg-mock"
    role_definition_resource_id = "/providers/Microsoft.Authorization/roleDefinitions/00000000-0000-0000-0000-000000000030"
  }
}

mock_resource "azurerm_storage_account" {
  defaults = {
    id                   = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Storage/storageAccounts/stmock"
    primary_dfs_endpoint = "https://stmock.dfs.core.windows.net/"
  }
}

mock_resource "azurerm_user_assigned_identity" {
  defaults = {
    id           = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-mock"
    principal_id = "00000000-0000-0000-0000-000000000010"
    client_id    = "00000000-0000-0000-0000-000000000011"
    tenant_id    = "00000000-0000-0000-0000-000000000001"
  }
}
