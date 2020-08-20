resource "azurerm_lb_backend_address_pool" "pool" {
  resource_group_name = azurerm_resource_group.resource_group.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "BackEndAddressPool"
}

resource "azurerm_public_ip" "pip_lb" {
  name                = "pip-${local.app_name}-dev"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb" {
  name                = "lb-${local.app_name}-dev"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip_lb.id
  }
}

resource "azurerm_lb_rule" "lb_rule_80" {
  resource_group_name            = azurerm_resource_group.resource_group.name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "LBRule80"
  protocol                       = "Tcp"
  frontend_port                  = 80   
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_probe" "hb_probe_80" {
  resource_group_name = azurerm_resource_group.resource_group.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "lbhp-port-80"
  port                = 80
}

resource "azurerm_lb_rule" "lb_rule_443" {
  resource_group_name            = azurerm_resource_group.resource_group.name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "LBRule443"
  protocol                       = "Tcp"
  frontend_port                  = 443     
  backend_port                   = 443
  frontend_ip_configuration_name = "PublicIPAddress"
}


resource "azurerm_lb_probe" "hb_probe_443" {
  resource_group_name = azurerm_resource_group.resource_group.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "lbhp-port-443"
  port                = 443
}

