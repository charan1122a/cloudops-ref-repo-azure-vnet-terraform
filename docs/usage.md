# Guía de Uso - Azure Networking Modules

## 🚀 Configuración Inicial

### Prerrequisitos
- Terraform >= 1.0.0
- Azure CLI >= 2.30.0
- Provider AzureRM >= 3.0.0

### Configuración Básica

```hcl
module "networking" {
  source = "."
  
  Project     = "MyProject"
  environment = "dev"
  location    = "East US"
  
  resource_group_name = {
    name = "rg-network-dev"
  }
  
  vnets = {
    primary = {
      address_space = ["10.0.0.0/16"]
      dns_servers   = ["10.0.0.4"]
    }
  }
}
```

## 🏗️ Patrones de Arquitectura

### Hub-Spoke
```hcl
# Hub VNet
module "hub_vnet" {
  source = "./modules/vnet"
  
  Project             = "HubSpoke"
  environment         = "prod"
  resource_group_name = "rg-hub-prod"
  location            = "East US"
  address_space       = ["10.0.0.0/16"]
}

# Peerings
module "hub_peerings" {
  source = "./modules/vnet_peering"
  
  virtual_network_name = module.hub_vnet.vnet_name
  peerings = {
    spoke1 = {
      remote_virtual_network_id = module.spoke1.vnet_id
      allow_gateway_transit     = true
    }
  }
}
```

### Multi-Tier Application
```hcl
subnet_config = {
  subnets = {
    web = {
      address_prefixes = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }
    app = {
      address_prefixes = ["10.0.2.0/24"]
      service_endpoints = ["Microsoft.KeyVault"]
    }
    db = {
      address_prefixes = ["10.0.3.0/24"]
      service_endpoints = ["Microsoft.Sql"]
      private_endpoint_network_policies_enabled = true
    }
  }
}
```

## 🔒 Configuraciones de Seguridad

### Network Security Groups
```hcl
resource "azurerm_network_security_group" "web_nsg" {
  name     = "nsg-web-${var.environment}"
  location = var.location
  
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
```

### Private Endpoints
```hcl
resource "azurerm_private_endpoint" "storage" {
  name                = "pe-storage-${var.environment}"
  subnet_id           = module.subnets.subnet_ids["endpoint"]
  
  private_service_connection {
    name                           = "psc-storage"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}
```

## 📊 Monitoreo

### Flow Logs
```hcl
resource "azurerm_network_watcher_flow_log" "main" {
  network_security_group_id = azurerm_network_security_group.main.id
  storage_account_id        = azurerm_storage_account.logs.id
  enabled                   = true
  
  retention_policy {
    enabled = true
    days    = 90
  }
}
```