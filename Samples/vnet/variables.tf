variable "project" {
  description = "Project name for the virtual network"
  type        = string
  validation {
    condition     = length(var.project) > 0 && length(var.project) <= 50
    error_message = "El nombre del proyecto debe tener entre 1 y 50 caracteres."
  }
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], lower(var.environment))
    error_message = "El ambiente debe ser dev, test o prod."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where the virtual network will be created"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  validation {
    condition = alltrue([
      for cidr in var.address_space : can(cidrhost(cidr, 0))
    ])
    error_message = "Todos los address_space deben ser bloques CIDR válidos."
  }
}

variable "dns_servers" {
  description = "Custom DNS servers"
  type        = list(string)
  default     = []
}

variable "bgp_community" {
  description = "BGP community for the virtual network"
  type        = string
  default     = null
}

variable "ddos_protection_plan_id" {
  description = "ID of the DDoS protection plan to associate with the virtual network"
  type        = string
  default     = null
}

variable "peerings" {
  description = "Map of virtual network peerings to create"
  type        = map(object({
    remote_virtual_network_id = string
    allow_virtual_network_access = optional(bool)
    allow_forwarded_traffic = optional(bool)
    allow_gateway_transit = optional(bool)
    use_remote_gateways = optional(bool)
  }))
  default     = {}
}

variable "enable_flow_logs" {
  description = "Whether to enable flow logs for the virtual network"
  type        = bool
  default     = false
}

variable "flow_log_nsg_id" {
  description = "ID of the network security group to enable flow logs for"
  type        = string
  default     = null
}

variable "flow_log_storage_account_id" {
  description = "ID of the storage account to store flow logs"
  type        = string
  default     = null
}

variable "flow_log_retention_days" {
  description = "Number of days to retain flow logs"
  type        = number
  default     = 90
}

variable "enable_traffic_analytics" {
  description = "Whether to enable traffic analytics for flow logs"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace for traffic analytics"
  type        = string
  default     = null
}

variable "log_analytics_workspace_resource_id" {
  description = "Resource ID of the Log Analytics workspace for traffic analytics"
  type        = string
  default     = null
}

variable "traffic_analytics_interval" {
  description = "Interval in minutes for traffic analytics"
  type        = number
  default     = 60
}

variable "network_watcher_name" {
  description = "Name of the Network Watcher to use for flow logs"
  type        = string
  default     = null
}

variable "network_watcher_resource_group_name" {
  description = "Resource group name of the Network Watcher to use for flow logs"
  type        = string
  default     = null
}

# Tags
variable "tags" {
  description = "Tags for the resource"
  type        = map(string)
  default     = {}
}

variable "create_default_route_table" {
  description = "Whether to create a default route table"
  type        = bool
  default     = false
}
