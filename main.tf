#There are steps that you must follow to create a virtual machine

# create a resource group
# create a virtual network
# create a subnet
# create a network interface card
# create a virtual machine (we can also create disks etc as a separate step)

terraform {
   required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "rg" {
  location = "eastus"
  name     = "azvm"
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  name                = "azvnet"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "azsubnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "networkinterface" {
  location            = azurerm_resource_group.rg.location
  name                = "aznetworkinterface"
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "aznetworkinterfaceip"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

# az vm image list --output table
# az vm image list --all
# az vm image list-offers -l westus -p MicrosoftWindowsServer
# az vm image list -f CentOS

resource "azurerm_windows_virtual_machine" "vm" {
  admin_password        = "india@123456"
  admin_username        = "india"
  location              = azurerm_resource_group.rg.location
  name                  = "winvm1"
  network_interface_ids = [azurerm_network_interface.networkinterface.id]
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = "standard_f2"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}