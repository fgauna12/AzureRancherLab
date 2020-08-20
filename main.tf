provider "azurerm" {
    features {}
}

locals {
    app_name = "rancherlab"
    resource_group_name = "rg-${local.app_name}-temp-002"
    node_count = 3
}

resource "azurerm_resource_group" "resource_group" {
  name     = local.resource_group_name
  location =  var.location
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_public_ip" "pip" {
  name                    = "pip-${local.app_name}-${count.index}-dev"
  location                = azurerm_resource_group.resource_group.location
  resource_group_name     = azurerm_resource_group.resource_group.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30

  count = local.node_count  
}

resource "azurerm_subnet" "main_subnet" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-${var.vnet_name}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal" #not really internal just don't want to rename because it won't let me. i'd have delete and recreate
    subnet_id                     = azurerm_subnet.main_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[count.index].id
  }

  count = local.node_count
}

resource "azurerm_storage_account" "vm_storage_account" {
  name                     = "st${local.app_name}002"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_availability_set" "availability_set" {
  name                = "vmas-${local.app_name}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.vm_name}${count.index}"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  size                = "Standard_DS2_v2"
  admin_username      = var.vm_admin_username
  availability_set_id = azurerm_availability_set.availability_set.id
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  count = local.node_count

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.vm_storage_account.primary_blob_endpoint
  }

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  provisioner "remote-exec" {
    script = "./init.sh"

    connection {
      host     = self.public_ip_address
      user     = self.admin_username
      private_key = file("~/.ssh/id_rsa")
    }
  
  }
}