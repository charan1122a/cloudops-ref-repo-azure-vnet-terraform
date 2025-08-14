variable "resource_group_name" {
  type    = map(string)
  description = "Nombre del grupo de recursos"
  validation {
    condition = can(var.resource_group_name.name) && length(var.resource_group_name.name) > 0
    error_message = "El nombre del grupo de recursos no puede estar vacío."
  }
}

variable "location" {
  type    = string
  description = "Región de Azure"
  validation {
    condition = contains(["East US", "West US", "Central US", "North Europe", "West Europe"], var.location)
    error_message = "La región debe ser una región válida de Azure."
  }
}

variable "project" {
  type    = string
  description = "Nombre del proyecto"
  default     = "SampleProject"
  validation {
    condition     = length(var.project) > 0 && length(var.project) <= 50
    error_message = "El nombre del proyecto debe tener entre 1 y 50 caracteres."
  }
}

variable "environment" {
  type    = string
  description = "Ambiente (dev, test, prod)"
  default     = "dev"
  validation {
    condition = contains(["dev", "test", "prod"], lower(var.environment))
    error_message = "El ambiente debe ser dev, test o prod."
  }
}

variable "department" {
  type = string
  description = "Departamento responsable"
  default = "IT"
}

variable "vnets" {
  description = "Map of virtual networks to create"
  type = map(object({
    address_space = list(string)
    dns_servers   = optional(list(string), [])
    bgp_community = optional(string, null)
    ddos_protection_plan_id = optional(string, null)
    tags  = optional(map(string), {})
    enable_flow_logs = optional(bool, false)
    flow_log_nsg_id = optional(string, null)
    flow_log_storage_account_id = optional(string, null)
    flow_log_retention_days = optional(number, 90)
    enable_traffic_analytics = optional(bool, false)
    log_analytics_workspace_id = optional(string, null)
    log_analytics_workspace_resource_id = optional(string, null)
    traffic_analytics_interval = optional(number, 60)
    network_watcher_name = optional(string, null)
    network_watcher_resource_group_name = optional(string, null)
  }))
  validation {
    condition = alltrue([for vnet in var.vnets : length(vnet.address_space) > 0])
    error_message = "Cada VNET debe tener al menos un espacio de direcciones."
  }
}

variable "vnet_peerings" {
  description = "Configuración de peerings de la red virtual"
  type = map(object({
    remote_virtual_network_id  = string
    allow_forwarded_traffic    = bool
    allow_virtual_network_access = bool
    allow_gateway_transit      = bool
    use_remote_gateways        = bool
  }))
}

variable "route_tables_config" {
  description = "Configuración de tablas de rutas"
  type = object({
    tags        = map(string)
    route_tables = map(object({
      name = optional(string)
      disable_bgp_route_propagation = optional(bool)
      routes = map(object({
        address_prefix = string
        next_hop_type = string
        next_hop_in_ip_address = optional(string)
      }))
      tags = optional(map(string))
    }))
  })
}

variable "subnet_config" {
  description = "Configuración de subnets"
  type = object({
    tags  = map(string)
    subnets = map(object({
      address_prefixes = list(string)
      service_endpoints = optional(list(string))
      private_endpoint_network_policies_enabled = optional(bool)
      private_link_service_network_policies_enabled = optional(bool)
      route_table_key = optional(string)
      tags = optional(map(string))
      delegations = optional(map(object({
        service_name = string
        actions = optional(list(string))
      })))
    }))
  })
}

variable "endpoint_key_vault" {
  type = object({
    is_manual_connection = bool
    name = string
    subresource_names = list(string)
  })
  validation {
    condition = length(var.endpoint_key_vault.name) > 0
    error_message = "El nombre del Key Vault no puede estar vacío."
  }
  validation {
    condition = contains(var.endpoint_key_vault.subresource_names, "vault")
    error_message = "Los subresource_names deben incluir 'vault'."
  }
}
