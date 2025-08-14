output "peering_ids" {
  description = "Map of peering names to IDs"
  value = {
    for key, peering in azurerm_virtual_network_peering.vnet_peering : key => peering.id
  }
}

output "peering_names" {
  description = "Map of peering keys to names"
  value = {
    for key, peering in azurerm_virtual_network_peering.vnet_peering : key => peering.name
  }
}
