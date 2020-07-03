resource "azurerm_public_ip" "ip" {
  name                = "${var.resource_name}-${var.resource_suffix}-pubip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku = "Standard"
}
resource "azurerm_lb" "lb" {
  name                = "${var.resource_name}-${var.resource_suffix}-lb"
  location            = var.location
  resource_group_name = var.resource_group
  sku = "Standard"
  
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "pool" {
  name                = "${var.resource_name}-${var.resource_suffix}-lbpool"
  resource_group_name = var.resource_group
  loadbalancer_id     = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "probe" {
  name                = "${var.resource_name}-${var.resource_suffix}-probe"
  resource_group_name = var.resource_group
  loadbalancer_id     = azurerm_lb.lb.id
  port                = 8080
}

resource "azurerm_lb_rule" "rule" {
  name                           = "${var.resource_name}-${var.resource_suffix}-rule"
  resource_group_name            = var.resource_group
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8080
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.pool.id
  probe_id                       = azurerm_lb_probe.probe.id
}

# resource "azurerm_lb_nat_rule" "rule" {
#   name                           = "${var.resource_name}-${var.resource_suffix}-http-rule"
#   resource_group_name            = var.resource_group
#   loadbalancer_id                = azurerm_lb.lb.id
#   protocol                       = "Tcp"
#   frontend_port                  = 80
#   backend_port                   = 8080
#   frontend_ip_configuration_name = "PublicIPAddress"
# }

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

# resource "azurerm_lb_outbound_rule" "test" {
#   resource_group_name     = var.resource_group
#   loadbalancer_id         = azurerm_lb.test.id
#   name                    = "OutboundRule"
#   protocol                = "Tcp"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.test.id

#   frontend_ip_configuration {
#     name = "PublicIPAddress"
#   }
# }

