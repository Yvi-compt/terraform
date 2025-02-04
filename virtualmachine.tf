resource "azurerm_resource_group" "vmlinuxrg" {
  name     = "virtual-m-linux-resources"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnetwork"
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.vmlinuxrg.location
  resource_group_name = azurerm_resource_group.vmlinuxrg.name
}

resource "azurerm_subnet" "subneta" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.vmlinuxrg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["192.168.2.0/24"]
}

resource "azurerm_network_interface" "interface" {
  name                = "net-interface-nic"
  location            = azurerm_resource_group.vmlinuxrg.location
  resource_group_name = azurerm_resource_group.vmlinuxrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subneta.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vmlinux" {
  name                = "virtual-machine-linux"
  resource_group_name = azurerm_resource_group.vmlinuxrg.name
  location            = azurerm_resource_group.vmlinuxrg.location
  size                = "Standard_F2"
  admin_username      = var.admin-user
  network_interface_ids = [
    azurerm_network_interface.interface.id,
  ]

  username      = var.admin-user

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
