output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value = {
    for key, subnet in azurerm_subnet.subnets : key => subnet.id
  }
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to address prefixes"
  value = {
    for key, subnet in azurerm_subnet.subnets : key => subnet.address_prefixes
  }
}
