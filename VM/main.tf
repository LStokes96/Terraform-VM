resource "azurerm_virtual_network" "ModuleVN" {
  name                = "Module-VN"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.Resource_group_name
}
resource "azurerm_public_ip" "example" {
  name                    = "test-pip"
  location                = var.location
  resource_group_name     = var.Resource_group_name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    environment = "test"
  }
}

resource "azurerm_subnet" "ModuleSub" {
  name                 = "internal"
  resource_group_name  = var.Resource_group_name
  virtual_network_name = azurerm_virtual_network.ModuleVN.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "ModuleNI" {
  name                = "Module-nic"
  location            = var.location
  resource_group_name = var.Resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ModuleSub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_linux_virtual_machine" "ModuleLinVM" {
  name                = "Module-Lin-VM"
  resource_group_name = var.Resource_group_name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.ModuleNI.id,
  ]
    admin_ssh_key {
    username   = "adminuser"
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
}
data "azurerm_public_ip" "example" {
  name                = azurerm_public_ip.example.name
  resource_group_name = var.Resource_group_name
}
