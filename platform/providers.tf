terraform {
  required_version = ">= 1.9.0"

  backend "azurerm" {
    # Partial configuration: pass resource_group_name, storage_account_name,
    # container_name and key (e.g. platform.tfstate) via -backend-config.
    use_azuread_auth = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.9"
    }
  }
}

provider "azurerm" {
  # Management groups are tenant-scoped; the subscription is only used for API calls.
  subscription_id = var.subscription_id
  features {}
}
