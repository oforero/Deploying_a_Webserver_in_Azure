provider "azurerm" {
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

module "network" {
  source               = "../../modules/network"
  address_space        = var.address_space
  location             = var.location
  virtual_network_name = var.virtual_network_name
  application_type     = var.application_type
  resource_type        = "NET"
  resource_group       = module.resource_group.resource_group_name
  address_prefix_test  = var.address_prefix_test
}

module "nsg" {
  source           = "../../modules/networksecuritygroup"
  location         = var.location
  application_type = var.application_type
  resource_type    = "NSG"
  resource_group   = module.resource_group.resource_group_name
  subnet_id        = module.network.subnet_id_test
  address_prefix_test = var.address_prefix_test
}

module "publicip" {
  source           = "../../modules/publicip"
  location         = var.location
  application_type = var.application_type
  resource_type    = "publicip"
  resource_group   = module.resource_group.resource_group_name
}

module "vm" {
  source           = "../../modules/vm"
  location         = var.location
  # application_type = var.application_type
  # resource_type    = "vm"
  resource_group   = module.resource_group.resource_group_name
  vm_subnet_id = module.network.subnet_id_test
  vm_public_ip_address_id = module.publicip.public_ip_address_id
  number_of_vms = var.number_of_vms
}