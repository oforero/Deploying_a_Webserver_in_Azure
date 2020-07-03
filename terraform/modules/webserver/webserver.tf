resource "azurerm_public_ip" "ip" {
  name                = "${var.resource_name}-${var.resource_suffix}-pubip-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group
  count               = var.use_load_balancer ? 0 : var.number_of_vms  
  allocation_method   = "Static"
  sku = "Standard"
}

resource "azurerm_availability_set" "as" {
  name                = "availability-set"
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_network_interface" "nic" {
  count = var.number_of_vms
  name                = "ProjectVM-eth0-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.ip[count.index].id
  }
}

data "azurerm_image" "img" {
  name                = "my-web-server"
  resource_group_name = "udacity-devops"
}

resource "azurerm_linux_virtual_machine" "vms" {
   depends_on = [
    azurerm_network_interface.nic
  ]
  count                 = var.number_of_vms
  name                  = "ProjectVM-${count.index}"
  location              = var.location
  resource_group_name   = var.resource_group
  size                  = "Standard_B1s"
  admin_username        = "oscar"
  availability_set_id   = azurerm_availability_set.as.id
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
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
  
  source_image_id = data.azurerm_image.img.id
}

resource "azurerm_network_interface_backend_address_pool_association" "pool" {
  depends_on = [
    azurerm_network_interface.nic
  ]

  count = var.use_load_balancer ? var.number_of_vms : 0
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = var.load_balancer_pool_id
}

