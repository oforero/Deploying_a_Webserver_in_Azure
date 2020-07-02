resource "azurerm_availability_set" "test" {
  name                = "availability-set"
  location            = var.location
  resource_group_name = var.resource_group
}