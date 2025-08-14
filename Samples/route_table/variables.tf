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

variable "route_tables" {
  description = "Mapa de tablas de rutas a crear o importar"
  type = map(object({
    name = optional(string)
    routes = optional(map(object({
      address_prefix = string
      next_hop_type = string
      next_hop_in_ip_address = optional(string)
    })))
    tags = optional(map(string))
  }))
  validation {
    condition = alltrue([
      for rt_key, rt in var.route_tables : alltrue([
        for route_key, route in coalesce(rt.routes, {}) : 
          contains(["Internet", "VnetLocal", "VirtualAppliance", "VirtualNetworkGateway", "None"], route.next_hop_type)
      ])
    ])
    error_message = "next_hop_type debe ser uno de: Internet, VnetLocal, VirtualAppliance, VirtualNetworkGateway, None."
  }
}
