terraform {
  required_version = ">= 0.14.8"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.51.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.3"
    }
  }
}