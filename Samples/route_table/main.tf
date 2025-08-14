resource "azurerm_route_table" "route_tables" {
  for_each = var.route_tables

  name                          = lookup(each.value, "name", join("_", [var.project, upper(each.key), var.environment, "RT"]))
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tags                          = lookup(each.value, "tags", {})
}

resource "azurerm_route" "routes" {
  for_each = {
    for route in flatten([
      for rt_key, rt in var.route_tables : [
        for route_key, route in lookup(rt, "routes", {}) : {
          id                    = "${rt_key}_${route_key}"
          rt_key                = rt_key
          name                  = route_key
          address_prefix        = route.address_prefix
          next_hop_type         = route.next_hop_type
          next_hop_in_ip_address = lookup(route, "next_hop_in_ip_address", null)
        }
      ] if lookup(rt, "routes", null) != null
    ]) : route.id => route
  }

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.route_tables[each.value.rt_key].name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}
