resource "azurerm_virtual_network" "network" {
  name                 = "${var.resource_name}-${var.resource_suffix}"
  address_space        = var.address_space
  location             = var.location
  resource_group_name  = var.resource_group
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.resource_name}-${var.resource_suffix}-subnet"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [var.address_prefix]
}

resource "azurerm_subnet_network_security_group_association" "test" {
    subnet_id                 = azurerm_subnet.subnet.id
    network_security_group_id = var.nsg_id
}