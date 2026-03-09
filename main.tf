terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-dimi"
    storage_account_name = "dimitest"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}
}

# bestehende Resource Group einlesen
data "azurerm_resource_group" "rg" {
  name = "rg-dimi"
}

# AKS Cluster erzeugen
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "dimi-aks-demo"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = "dimiaksdemo"

  default_node_pool {
    name       = "diminpool"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}