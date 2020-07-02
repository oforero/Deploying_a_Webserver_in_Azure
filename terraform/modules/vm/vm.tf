resource "azurerm_network_interface" "test" {
  name                = "ProjectVM-eth0"
  location            = var.location
  resource_group_name = var.resource_group
  count = var.number_of_vms

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.vm_public_ip_address_id
  }
}

data "azurerm_image" "custom" {
  name                = "my-web-server"
  resource_group_name = "udacity-devops"
}

resource "azurerm_linux_virtual_machine" "test" {
  name                  = "ProjectVM"
  location              = var.location
  resource_group_name   = var.resource_group
  size                  = "Standard_B1s"
  admin_username        = "oscar"
  count                 = var.number_of_vms
  availability_set_id   = var.availability_set
  network_interface_ids = [element(azurerm_network_interface.test.*.id, count.index)]
  tags = {
    job = "Webserver"
  }

  admin_ssh_key {
    username   = "oscar"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  
  os_disk {
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  source_image_id = data.azurerm_image.custom.id
  
  # source_image_reference {
  #   publisher = "Canonical"
  #   offer     = "UbuntuServer"
  #   sku       = "18.04-LTS"
  #   version   = "latest"
  # }
}
