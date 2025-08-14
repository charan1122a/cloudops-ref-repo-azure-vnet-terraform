output "route_table_ids" {
  description = "Map of route table names to IDs"
  value = {
    for key, rt in azurerm_route_table.route_tables : key => rt.id
  }
}

output "route_table_names" {
  description = "Map of route table keys to names"
  value = {
    for key, rt in azurerm_route_table.route_tables : key => rt.name
  }
}

output "routes" {
  description = "Map of routes created"
  value = {
    for key, route in azurerm_route.routes : key => {
      name = route.name
      address_prefix = route.address_prefix
      next_hop_type = route.next_hop_type
      next_hop_in_ip_address = route.next_hop_in_ip_address
    }
  }
}
