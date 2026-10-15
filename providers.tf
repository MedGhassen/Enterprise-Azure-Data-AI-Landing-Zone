terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {
    # Partial config: pass resource_group_name, storage_account_name, container_name, key via -backend-config
    # Example: terraform init -backend-config="resource_group_name=rg-terraform-state" -backend-config="storage_account_name=mystorage" -backend-config="container_name=tfstate" -backend-config="key=data-ai-landing-zone.tfstate"
    use_azuread_auth = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.12"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.35"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

provider "azuread" {}

provider "azapi" {}

# Databricks provider: set host via env DATABRICKS_HOST or in CI after workspace is created
provider "databricks" {}
