locals {
  service_names = {
    "web"        = "WEB"
    "app"        = "APP"
    "data"       = "DATA"
    "management" = "MGMT"
  }
  
  subnet_names = {
    for key, subnet in var.subnets : key => 
      join("-", ["subnet", var.project, lookup(local.service_names, key, upper(key)), var.environment])
  }
  
}


resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = local.subnet_names[each.key]
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = each.value.address_prefixes
  
  service_endpoints    = lookup(each.value, "service_endpoints", null)
  
  private_link_service_network_policies_enabled = lookup(each.value, "private_link_service_network_policies_enabled", false)
  dynamic "delegation" {
    for_each = lookup(each.value, "delegations", null) != null ? lookup(each.value, "delegations", {}) : {}
    
    content {
      name = delegation.key
      
      service_delegation {
        name    = delegation.value.service_name
        actions = lookup(delegation.value, "actions", null)
      }
    }
  }
  
  lifecycle {
    ignore_changes = [
      delegation
    ]
    prevent_destroy = true
  }
  
}

resource "azurerm_subnet_route_table_association" "subnet_route_table_associations" {
  for_each = {
    for key, subnet in var.subnets : key => subnet
    if lookup(subnet, "route_table_key", null) != null && contains(keys(var.route_table_ids), subnet.route_table_key)
  }

  subnet_id      = azurerm_subnet.subnets[each.key].id
  route_table_id = var.route_table_ids[each.value.route_table_key]
  
  depends_on = [azurerm_subnet.subnets]
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_associations" {
  for_each = {
    for key, subnet in var.subnets : key => subnet
    if lookup(subnet, "network_security_group_id", null) != null
  }

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = each.value.network_security_group_id
}
