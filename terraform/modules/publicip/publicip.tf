resource "azurerm_public_ip" "test" {
  name                = "${var.application_type}-${var.resource_type}-pubip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku = "Standard"
}

# resource "azurerm_dns_zone" "test" {
#   name                = ".eastus.cloudapp.azure.com"
#   resource_group_name = var.resource_group
# }

# resource "azurerm_dns_a_record" "test" {
#   name                = "udacity-web-oforero"
#   zone_name           = azurerm_dns_zone.test.name
#   resource_group_name = var.resource_group
#   ttl                 = 300
#   target_resource_id  = azurerm_public_ip.test.id
# }