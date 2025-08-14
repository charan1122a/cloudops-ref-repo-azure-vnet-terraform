variable "project" {
  description = "Nombre del proyecto"
  type        = string
  validation {
    condition     = length(var.project) > 0 && length(var.project) <= 50
    error_message = "El nombre del proyecto debe tener entre 1 y 50 caracteres."
  }
}

variable "environment" {
  description = "Ambiente (dev, test, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], lower(var.environment))
    error_message = "El ambiente debe ser dev, test o prod."
  }
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
}

variable "location" {
  description = "Región de Azure"
  type        = string
}

variable "virtual_network_name" {
  description = "Nombre de la red virtual"
  type        = string
}

variable "subnets" {
  description = "Mapa de subnets a crear"
  type = map(object({
    address_prefixes = list(string)
    service_endpoints = optional(list(string))
    private_endpoint_network_policies_enabled = optional(bool)
    private_link_service_network_policies_enabled = optional(bool)
    network_security_group_id = optional(string)
    route_table_key = optional(string)
    tags = optional(map(string))
    delegations = optional(map(object({
      service_name = string
      actions = optional(list(string))
    })))
  }))
  validation {
    condition = alltrue([
      for k, v in var.subnets : k != "default" && !startswith(k, "GatewaySubnet")
    ])
    error_message = "No se permite usar 'default' o subnets que empiecen con 'GatewaySubnet'."
  }
}

variable "route_table_ids" {
  description = "Mapa de IDs de tablas de rutas para asociar con subnets"
  type        = map(string)
}

variable "tags" {
  description = "Tags para los recursos"
  type        = map(string)
}
