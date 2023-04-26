terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.4.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "anas-st-dont-remove"
    storage_account_name = "xanas"
    container_name       = "tfstate"
    key                  = "aks.terraform.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aks" {
  name     = "aks-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "aks" {
  name                = "aks-vnet-westeur"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = ["10.3.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-snet"
  resource_group_name  = azurerm_resource_group.aks.name
  address_prefixes     = ["10.3.1.0/24"]
  virtual_network_name = azurerm_virtual_network.aks.name
}

resource "azurerm_subnet" "appgw" {
  name                 = "appgw-snet"
  resource_group_name  = azurerm_resource_group.aks.name
  address_prefixes     = ["10.3.2.0/24"]
  virtual_network_name = azurerm_virtual_network.aks.name
}

resource "azurerm_kubernetes_cluster" "aks" {
  depends_on = [
    azurerm_virtual_network.aks
  ]
  name                = "aks-test-westeur"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "akstestwesteur"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "standard_b2s"
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }

  ingress_application_gateway {
    gateway_name = "aks-appgw-westeur"
    subnet_id    = azurerm_subnet.appgw.id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}
