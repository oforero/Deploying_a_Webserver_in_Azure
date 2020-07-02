resource "azurerm_network_interface" "test" {
  count = var.number_of_vms
  name                = "ProjectVM-eth0-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

data "azurerm_image" "test" {
  name                = "my-web-server"
  resource_group_name = "udacity-devops"
}

resource "azurerm_linux_virtual_machine" "test" {
   depends_on = [
    azurerm_network_interface.test
  ]
  count                 = var.number_of_vms
  name                  = "ProjectVM-${count.index}"
  location              = var.location
  resource_group_name   = var.resource_group
  size                  = "Standard_B1s"
  admin_username        = "oscar"
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
  
  source_image_id = data.azurerm_image.test.id
}

resource "azurerm_network_interface_backend_address_pool_association" "test" {
  depends_on = [
    azurerm_network_interface.test
  ]

  count = var.number_of_vms
  network_interface_id    = azurerm_network_interface.test[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = var.load_balancer
}

