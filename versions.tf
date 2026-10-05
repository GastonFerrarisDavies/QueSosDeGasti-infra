terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # El estado vive en un Storage Account creado a mano (ver README).
  # Los nombres están en backend.hcl: terraform init -backend-config=backend.hcl
  backend "azurerm" {
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}
  # subscription_id, tenant_id y client_id llegan por ARM_* (CI) o por `az login` (local).
}
