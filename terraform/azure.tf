# terraform/azure.tf

# Configure the Azure Provider
provider "azurerm" {
    subscription_id = "47047006-5165-4ccb-88ee-1b8e9c8b4256"
  features {}
}

# Create a Resource Group to hold all our Azure resources
resource "azurerm_resource_group" "aks_rg" {
  name     = "my-app-aks-rg"
  location = "East US"
}

# Create the AKS (Azure Kubernetes Service) cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "my-app-aks-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "myappaks" // Must be unique across Azure

  default_node_pool {
    name       = "defaultpool"
    node_count = 1 // Start with 1 node to keep it cheap
    vm_size    = "Standard_B2s" // A good, cheap, burstable VM size
  }

  // Use a system-assigned identity for simplicity
  identity {
    type = "SystemAssigned"
  }

  # Add a tag to identify the project
  tags = {
    project = "multi-cloud-devops-pipeline"
  }
}