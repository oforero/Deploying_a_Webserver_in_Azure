provider "azurerm" {
  version = "~> 2.16"
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  features {}
}

terraform {
  backend "local" {
    path = ".terraform/terraform.tfstate"
  }
}

resource "azurerm_resource_group" "test" {
  name     = var.resource_group
  location = var.location
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.application_name}-NSG"
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "AllInbound-Deny"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "VNet-Inbound-Allow"
    priority                   = 4050
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "HTTP-Inbound-Allow"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }


  security_rule {
    name                       = "AllOutbound-Deny"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "VNet-Outbound-Allow"
    priority                   = 4050
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_virtual_network" "network" {
  name                 = "${var.application_name}-NET"
  address_space        = var.address_space
  location             = var.location
  resource_group_name  = var.resource_group
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.application_name}-SUBNET"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [var.address_prefix]
}

resource "azurerm_subnet_network_security_group_association" "test" {
    subnet_id                 = azurerm_subnet.subnet.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "lb" {
  name                = "${var.application_name}-LB-pubip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku = "Standard"
}

resource "azurerm_lb" "lb" {
  name                = "${var.application_name}-lb"
  location            = var.location
  resource_group_name = var.resource_group
  sku = "Standard"
  
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "pool" {
  name                = "${var.application_name}-lbpool"
  resource_group_name = var.resource_group
  loadbalancer_id     = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "probe" {
  name                = "${var.application_name}-probe"
  resource_group_name = var.resource_group
  loadbalancer_id     = azurerm_lb.lb.id
  port                = 8080
}

resource "azurerm_lb_rule" "rule" {
  name                           = "${var.application_name}-rule"
  resource_group_name            = var.resource_group
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8080
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.pool.id
  probe_id                       = azurerm_lb_probe.probe.id
}

resource "azurerm_public_ip" "ip" {
  name                = "${var.application_name}-vm-pubip-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group
  count               = var.number_of_vms  
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
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.ip[count.index].id
  }
}

data "azurerm_image" "img" {
  name                = var.packer_image
  resource_group_name = var.packer_image_group
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

  count = var.number_of_vms
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool.id
}
