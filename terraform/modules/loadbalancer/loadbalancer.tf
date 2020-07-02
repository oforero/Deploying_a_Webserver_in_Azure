resource "azurerm_lb" "test" {
  name                = "udacity-loadbalancer"
  location            = var.location
  resource_group_name = var.resource_group
  sku = "Standard"
  
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = var.public_ip
  }
}

resource "azurerm_lb_backend_address_pool" "test" {
  resource_group_name = var.resource_group
  loadbalancer_id     = azurerm_lb.test.id
  name                = "lb-backend-pool"
}

# resource "azurerm_lb_rule" "test" {
#   resource_group_name     = var.resource_group
#   loadbalancer_id         = azurerm_lb.test.id
#   name                    = "LBRule"
#   protocol                = "Tcp"
#   frontend_port           = 80
#   backend_port            = 80
#   disable_outbound_snat   = true
#   backend_address_pool_id = azurerm_lb_backend_address_pool.test.id
#   frontend_ip_configuration_name = "PublicIPAddress"

# }

resource "azurerm_lb_outbound_rule" "test" {
  resource_group_name     = var.resource_group
  loadbalancer_id         = azurerm_lb.test.id
  name                    = "OutboundRule"
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id

  frontend_ip_configuration {
    name = "PublicIPAddress"
  }
}

