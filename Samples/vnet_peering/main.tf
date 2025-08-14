locals {
  vnet_name = join("_", [var.project, "VNET", var.environment])
  
  peering_names = {
    for key, peering in var.peerings : key => 
      lookup(peering, "prefix", null) != null ? 
        "${peering.prefix}-${local.vnet_name}" : 
        "${key}-${local.vnet_name}"
  }
}

resource "azurerm_virtual_network_peering" "vnet_peering" {
  for_each                     = var.peerings
  
  name                         = local.peering_names[each.key]
  resource_group_name          = var.resource_group_name
  virtual_network_name         = var.virtual_network_name
  remote_virtual_network_id    = each.value.remote_virtual_network_id
  
  allow_virtual_network_access = each.value.allow_virtual_network_access
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
  use_remote_gateways          = each.value.use_remote_gateways
  
  lifecycle {
    prevent_destroy = true
  }
}
