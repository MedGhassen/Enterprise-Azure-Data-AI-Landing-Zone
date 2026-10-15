terraform {
  required_version = ">= 1.9.0"

  backend "azurerm" {
    # Partial configuration: pass resource_group_name, storage_account_name,
    # container_name and key via -backend-config (see scripts/bootstrap-state.sh).
    use_azuread_auth = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.9"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  # null falls back to the ARM_SUBSCRIPTION_ID environment variable / Azure CLI context.
  subscription_id = var.subscription_id

  # Data-plane storage operations use Entra ID (shared-key access is disabled on all accounts).
  storage_use_azuread = true

  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}
