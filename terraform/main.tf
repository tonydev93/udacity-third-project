provider "azurerm" {
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  features {}
}
terraform {
  backend "azurerm" {
    storage_account_name = "tonystorageaccount01"
    container_name       = "tonycontainer01"
    key                  = "tonyterraform.key"
    access_key           = "HHtVvXI6XbRxy33yz6AcM0EmY0ltJxaZljMS3aao4BZ3kAep7AYfLY4OziYfiMwePzGFNJkLfPHv+AStbYLQMA=="
  }
}
module "resource_group" {
  source               = "./modules/resource_group"
  resource_group       = "${var.resource_group}"
  location             = "${var.location}"
}
module "network" {
  source               = "./modules/network"
  address_space        = "${var.address_space}"
  location             = "${var.location}"
  virtual_network_name = "${var.virtual_network_name}"
  application_type     = "${var.application_type}"
  resource_type        = "NET"
  resource_group       = "${module.resource_group.resource_group_name}"
  address_prefix_test  = "${var.address_prefix_test}"
}

module "nsg-test" {
  source           = "./modules/networksecuritygroup"
  location         = "${var.location}"
  application_type = "${var.application_type}"
  resource_type    = "NSG"
  resource_group   = "${module.resource_group.resource_group_name}"
  subnet_id        = "${module.network.subnet_id_main}"
  address_prefix_test = "${var.address_prefix_test}"
}
module "appservice" {
  source           = "./modules/appservice"
  location         = "${var.location}"
  application_type = "${var.application_type}"
  resource_type    = "AppService"
  resource_group   = "${module.resource_group.resource_group_name}"
}
module "publicip" {
  source           = "./modules/publicip"
  location         = "${var.location}"
  application_type = "${var.application_type}"
  resource_type    = "publicip"
  resource_group   = "${module.resource_group.resource_group_name}"
}

module "vm" {
  source                           = "./modules/vm"
  location                         = var.location
  application_type                 = var.application_type
  resource_type                    = "vm"
  resource_group_name              = module.resource_group.resource_group_name
  public_ip_address_id             = module.publicip.public_ip_address_id
  subnet_id                        = module.network.subnet_id_main
  log_analytics_workspace_id       = module.log_analytics_workspace.log_analytics_workspace_id
  log_analytics_primary_shared_key = module.log_analytics_workspace.log_analytics_primary_shared_key
}

module "log_analytics_workspace" {
  source              = "./modules/log_analytics"
  location = var.location
  resource_group_name = module.resource_group.resource_group_name
}