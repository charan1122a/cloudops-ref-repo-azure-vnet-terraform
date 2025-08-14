variable "resource_group_name" {
  description = "Nombre del grupo de recursos donde se encuentra la red virtual"
  type        = string
}

variable "virtual_network_name" {
  description = "Nombre de la red virtual origen para el peering"
  type        = string
}

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

variable "peerings" {
  description = "Configuración de peerings de la red virtual"
  type = map(object({
    remote_virtual_network_id  = string
    allow_forwarded_traffic    = bool
    allow_virtual_network_access = bool
    allow_gateway_transit      = bool
    use_remote_gateways        = bool
    prefix                     = optional(string)
  }))
  validation {
    condition = alltrue([
      for k, v in var.peerings : !(v.allow_gateway_transit && v.use_remote_gateways)
    ])
    error_message = "No se puede usar allow_gateway_transit y use_remote_gateways simultáneamente."
  }
}
