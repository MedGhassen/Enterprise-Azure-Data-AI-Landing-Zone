# Offline tests: run from ./platform with `terraform init -backend=false && terraform test`.

mock_provider "azurerm" {
  source = "../tests/mocks"
}

variables {
  management_group_prefix = "contoso"
  allowed_locations       = ["westeurope"]
}

run "baseline_hierarchy" {
  command = apply

  assert {
    condition     = length(module.governance.management_group_ids) == 8
    error_message = "Expected Platform, Landing Zones, Sandbox, Management, Connectivity and three Data & AI management groups."
  }

  assert {
    condition     = length(module.governance.custom_role_definition_ids) == 3
    error_message = "Expected the three default custom roles."
  }

  assert {
    # allowed locations + (require + inherit) x 3 default tags
    condition     = length(module.governance.policy_assignment_ids) == 7
    error_message = "Expected baseline policy assignments only."
  }
}

run "compliance_and_identity" {
  command = apply

  variables {
    create_identity_management_group = true
    enable_iso27001                  = true
    enable_nis2                      = true
    nis2_initiative_id               = "/providers/Microsoft.Management/managementGroups/contoso/providers/Microsoft.Authorization/policySetDefinitions/nis2"
    subscription_placement           = { dataai_dev = "00000000-0000-0000-0000-000000000099" }
  }

  assert {
    condition     = contains(keys(module.governance.management_group_ids), "identity")
    error_message = "Identity management group expected."
  }

  assert {
    condition     = contains(keys(module.governance.policy_assignment_ids), "compliance-iso27001") && contains(keys(module.governance.policy_assignment_ids), "compliance-nis2")
    error_message = "ISO 27001 and NIS2 assignments expected."
  }
}

run "rejects_unknown_subscription_key" {
  command = plan

  variables {
    subscription_placement = { finance = "00000000-0000-0000-0000-000000000099" }
  }

  expect_failures = [var.subscription_placement]
}
