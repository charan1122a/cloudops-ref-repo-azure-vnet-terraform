data "azurerm_resource_group" "resource" {
  name = var.resource_group_name.name
}

data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "nova_key" {
  name                = var.endpoint_key_vault["name"]
  resource_group_name = var.resource_group_name.name
}