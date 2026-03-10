terraform {

  # Definition der benötigten Provider
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm" # Provider kommt aus der offiziellen HashiCorp Registry
      version = "~>3.0"             # erlaubt Version 3.x (aber nicht 4.x)
    }
  }

  # Remote Backend für Terraform State
  backend "azurerm" {
    # Resource Group in der der Storage Account liegt
    resource_group_name  = "rg-dimi"
    # Name des Azure Storage Accounts
    storage_account_name = "dimitest"
    # Container im Storage Account; dort wird die tfstate Datei gespeichert
    container_name       = "tfstate"
    # Name der Terraform State Datei
    key                  = "terraform.tfstate"
    # Authentifizierung über Azure AD statt Storage Keys
    use_azuread_auth     = true
  }
}

# Konfiguration des Azure Providers
provider "azurerm" {
  # ist verpflichtend für den azurerm provider; könnten später zusätzliche Provider Features konfiguriert werden
  features {}
}

# Bestehende Azure Resource Group auslesen; liest Informationen daraus
data "azurerm_resource_group" "rg" {
  name = "rg-dimi"
}

# AKS Cluster erzeugen
resource "azurerm_kubernetes_cluster" "aks" {
  # Name des AKS Clusters
  name                = "dimi-aks-demo"
  # Standort wird aus der zuvor geladenen Resource Group übernommen
  location            = data.azurerm_resource_group.rg.location
  # Resource Group des Clusters
  resource_group_name = data.azurerm_resource_group.rg.name
  # DNS Prefix für die Kubernetes API Endpoint URL
  dns_prefix          = "dimiaksdemo"

  # Node Pool Konfiguration
  default_node_pool {
    # Name des Node Pools
    name       = "diminpool"
    # Anzahl der Worker Nodes
    node_count = 1
    # VM Größe der Nodes
    vm_size    = "Standard_B2ps_v2"
  }

  identity {
    # SystemAssigned bedeutet: Azure erstellt automatisch eine Managed Identity für AKS
    type = "SystemAssigned"
  }
}