# Offline tests: run with `terraform init -backend=false && terraform test`.
# Providers are mocked, so no Azure credentials are needed and nothing is deployed.

mock_provider "azurerm" {
  source = "./tests/mocks"
}

mock_provider "random" {}

# Azure validates that these resources reference subnets with reserved names.
override_resource {
  target = module.networking.azurerm_subnet.gateway
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/virtualNetworks/vnet-hub/subnets/GatewaySubnet"
  }
}

override_resource {
  target = module.networking.azurerm_subnet.firewall
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/virtualNetworks/vnet-hub/subnets/AzureFirewallSubnet"
  }
}

override_resource {
  target = module.networking.azurerm_subnet.bastion
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000004/resourceGroups/rg-mock/providers/Microsoft.Network/virtualNetworks/vnet-hub/subnets/AzureBastionSubnet"
  }
}


variables {
  cost_center = "CC-TEST"
  owner_email = "owner@example.com"
}

run "dev_profile" {
  command = apply

  variables {
    environment                = "dev"
    unique_suffix              = "ab12"
    enable_firewall            = false
    enable_vpn_gateway         = true
    key_vault_purge_protection = false
    cosmos_serverless          = true
    aks_sku_tier               = "Free"
  }

  assert {
    condition     = module.networking.firewall_private_ip == null
    error_message = "Firewall must not be deployed when enable_firewall = false."
  }

  assert {
    condition     = module.networking.vpn_gateway_id != null
    error_message = "VPN gateway must be deployed when enable_vpn_gateway = true."
  }

  assert {
    condition     = module.serving.aks_id != null && module.serving.aks_outbound_type == "loadBalancer"
    error_message = "AKS must use load balancer egress without a firewall."
  }

  assert {
    condition     = length(azurerm_management_lock.rg) == 0
    error_message = "No resource locks expected in dev."
  }

  assert {
    condition     = alltrue([for rg in azurerm_resource_group.this : startswith(rg.name, "rg-dataai-dev-weu-")])
    error_message = "Resource groups must follow rg-{prefix}-{env}-{region}-{role}-{instance}."
  }
}

run "prod_profile" {
  command = apply

  variables {
    environment           = "prod"
    unique_suffix         = "cd34"
    enable_firewall       = true
    enable_bastion        = true
    enable_resource_locks = true
    enable_purview        = true
    enable_flow_logs      = true
  }

  assert {
    condition     = module.networking.firewall_policy_id != null && module.networking.serving_route_table_id != null
    error_message = "Firewall policy and serving route table expected in prod."
  }

  assert {
    condition     = module.serving.aks_outbound_type == "userDefinedRouting"
    error_message = "AKS must egress through the firewall (userDefinedRouting) in prod."
  }

  assert {
    condition     = length(azurerm_management_lock.rg) == 5
    error_message = "Every workload resource group must be locked in prod."
  }

  assert {
    condition     = module.serving.purview_account_id != null
    error_message = "Purview expected when enable_purview = true."
  }
}

run "minimal_profile" {
  command = plan

  variables {
    environment         = "dev"
    unique_suffix       = "ef56"
    enable_firewall     = false
    enable_databricks   = false
    enable_synapse      = false
    enable_sql_database = false
    enable_cosmos_db    = false
    enable_event_hubs   = false
    enable_ml_workspace = false
    enable_aks          = false
  }

  assert {
    condition     = length(module.databricks) == 0 && length(module.synapse) == 0 && length(module.databases) == 0 && length(module.streaming) == 0
    error_message = "Disabled workloads must not be deployed."
  }

  assert {
    condition     = length(module.ai) == 1 && length(module.data_factory) == 1
    error_message = "Foundry/Search and Data Factory remain enabled in the minimal profile."
  }
}

run "globally_unique_names_fit_limits" {
  command = plan

  variables {
    environment     = "staging"
    location        = "germanywestcentral"
    resource_prefix = "abcdefghij"
    unique_suffix   = "zz99"
  }

  assert {
    condition     = length(module.data_lake.storage_account_name) <= 24 && can(regex("^[a-z0-9]+$", module.data_lake.storage_account_name))
    error_message = "Storage account name must be <= 24 lowercase alphanumerics."
  }

  assert {
    condition     = length(module.security.key_vault_name) <= 24
    error_message = "Key Vault name must be <= 24 characters."
  }

  assert {
    condition     = endswith(module.data_lake.storage_account_name, "zz99001") && endswith(module.security.key_vault_name, "zz99001")
    error_message = "Globally unique names must keep the unique suffix and instance after truncation."
  }
}

run "rejects_invalid_environment" {
  command = plan

  variables {
    environment = "qa"
  }

  expect_failures = [var.environment]
}

run "rejects_invalid_prefix" {
  command = plan

  variables {
    environment     = "dev"
    resource_prefix = "Data_AI"
  }

  expect_failures = [var.resource_prefix]
}

run "rejects_unsupported_region" {
  command = plan

  variables {
    environment = "dev"
    location    = "marsnorth"
  }

  expect_failures = [var.location]
}

run "rejects_invalid_unique_suffix" {
  command = plan

  variables {
    environment   = "dev"
    unique_suffix = "TOO-LONG"
  }

  expect_failures = [var.unique_suffix]
}
