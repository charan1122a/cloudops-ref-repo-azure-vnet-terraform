module "vnet" {
  source = "./modules/vnet"
  
  project            = var.project
  environment        = var.environment
  resource_group_name = var.resource_group_name.name
  location            = var.location
  address_space       = var.vnets["primary"].address_space
  
  dns_servers         = var.vnets["primary"].dns_servers
  bgp_community       = lookup(var.vnets["primary"], "bgp_community", null)
  ddos_protection_plan_id = lookup(var.vnets["primary"], "ddos_protection_plan_id", null)
  
  tags = var.vnets["primary"].tags
}

module "vnet_peering" {
  source = "./modules/vnet_peering"
  
  resource_group_name  = var.resource_group_name.name
  virtual_network_name = module.vnet.vnet_name
  project             = var.project
  environment         = var.environment
  peerings             = var.vnet_peerings
}

module "route_tables" {
  source = "./modules/route_table"
  
  project           = var.project
  environment        = var.environment
  resource_group_name = var.resource_group_name.name
  location           = var.location
  route_tables       = var.route_tables_config.route_tables
}

module "subnets" {
  source = "./modules/subnet"

  project            = var.project
  environment         = var.environment
  resource_group_name = var.resource_group_name.name
  virtual_network_name = module.vnet.vnet_name
  location            = var.location
  tags                = var.subnet_config.tags
  
  subnets = var.subnet_config.subnets
  
  route_table_ids = module.route_tables.route_table_ids
}