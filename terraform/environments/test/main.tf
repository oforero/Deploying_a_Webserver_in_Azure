provider "azurerm" {
  version = "~> 2.16"
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "udacity-devops"
    storage_account_name = "oforeroterraform"
    container_name       = "terraform"
    key                  = "9mGB2WFwLvj3E9zGS+NheXLox5qT2Rj5b0qIQ4F1OnDlCcQ/C+MYbTbAmtWuLstAUe9HrytTjPBHscecr3fR6Q=="
    access_key           = ""
  }
}

module "resource_group" {
  source         = "../../modules/resource_group"
  resource_group = var.resource_group
  location       = var.location
}

module "nsg" {
  source           = "../../modules/permissive-nsg"
  resource_name = var.application_name
  location         = var.location
  resource_group   = module.resource_group.resource_group_name
}

module "network" {
  source               = "../../modules/network"
  resource_name        = var.application_name
  location             = var.location
  resource_group       = module.resource_group.resource_group_name

  virtual_network_name = var.virtual_network_name
  address_space        = var.address_space
  address_prefix       = var.address_prefix
  nsg_id               = module.nsg.nsg_id
}

module "loadbalancer" {
  source           = "../../modules/loadbalancer"
  location         = var.location
  resource_group   = module.resource_group.resource_group_name
  resource_name    = var.application_name
}

module "webserver" {
  source           = "../../modules/webserver"
  location         = var.location
  resource_name    = var.application_name
  resource_group   = module.resource_group.resource_group_name
  vm_subnet_id     = module.network.subnet_id
  number_of_vms    = var.number_of_vms
  use_load_balancer     = true
  load_balancer_pool_id = module.loadbalancer.load_balancer_pool_id
}

# module "publicip" {
#   source           = "../../modules/publicip"
#   location         = var.location
#   application_type = var.application_type
#   resource_type    = "publicip"
#   resource_group   = module.resource_group.resource_group_name
# }

# module "availabilityset" {
#   source           = "../../modules/availabilityset"
#   location         = var.location
#   resource_group   = module.resource_group.resource_group_name
# }

