output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_address_space" {
  description = "Address space of the virtual network"
  value       = azurerm_virtual_network.vnet.address_space
}

output "vnet_guid" {
  description = "The GUID of the virtual network"
  value       = azurerm_virtual_network.vnet.guid
}

output "vnet_location" {
  description = "Location of the virtual network"
  value       = azurerm_virtual_network.vnet.location
}

output "vnet_resource_group_name" {
  description = "Resource group name of the virtual network"
  value       = azurerm_virtual_network.vnet.resource_group_name
}
