# **Módulo Terraform: cloudops-ref-repo-azure-vnet-terraform**

## Descripción:

Este módulo facilita la creación de una infraestructura de red completa en Azure, proporcionando configuraciones de Virtual Networks (VNets), subnets, tablas de enrutamiento y peerings. Incluye la creación de subnets segmentadas por capas, route tables personalizadas, VNet peerings y Network Security Groups para una gestión eficiente y segura de la red.

Este módulo de Terraform para Azure VNet realizará las siguientes acciones:

- Crear una VNet con el address space especificado.
- Crear subnets segmentadas por dominio funcional (web, app, data, management).
- Configurar tablas de enrutamiento para cada subnet.
- Crear VNet peerings con configuración de tráfico controlada.
- Configurar Network Security Groups para protección de recursos.
- Implementar Flow Logs para monitoreo y auditoría del tráfico de red.
- Configurar Private Endpoints para servicios de Azure.

Consulta CHANGELOG.md para la lista de cambios de cada versión. *Recomendamos encarecidamente que en tu código fijes la versión exacta que estás utilizando para que tu infraestructura permanezca estable y actualices las versiones de manera sistemática para evitar sorpresas.*

## Estructura del Módulo

```bash
cloudops-ref-repo-azure-vnet-terraform/
├── Modules/
│   ├── vnet/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── subnet/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── vnet_peering/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── route_table/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
├── docs/
│   ├── usage.md
│   └── troubleshooting.md
├── .gitignore
├── CHANGELOG.md
├── backend.tf
├── data.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars
├── terraform.tfvars.example
├── variables.tf
└── README.md
```

## Seguridad & Cumplimiento

Consulta a continuación la fecha y los resultados de nuestro escaneo de seguridad y cumplimiento.

<!-- BEGIN_BENCHMARK_TABLE -->
| Benchmark | Date | Version | Description | 
| --------- | ---- | ------- | ----------- | 
| ![checkov](https://img.shields.io/badge/checkov-passed-green) | 2024-08-14 | 3.2.461 | Escaneo profundo del plan de Terraform en busca de problemas de seguridad y cumplimiento |
| ![tflint](https://img.shields.io/badge/tflint-passed-green) | 2024-01-15 | 0.58.1 | Análisis estático de código Terraform para mejores prácticas |
<!-- END_BENCHMARK_TABLE -->

## Provider Configuration

Este módulo requiere la configuración del provider AzureRM. Debe configurarse de la siguiente manera:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

## Uso del Módulo:

```hcl
module "azure_networking" {
  source = "git::https://github.com/your-org/cloudops-ref-repo-azure-vnet-terraform.git"
  
  # Configuración común
  project     = "SampleProject"
  environment = "dev"
  location    = "East US"
  department  = "IT"
  
  resource_group_name = {
    name = "rg-sample-network"
  }

  # Configuración de VNet
  vnets = {
    primary = {
      address_space = ["10.0.0.0/16"]
      dns_servers   = ["10.0.0.4", "10.0.0.5"]
      tags = {
        Application = "sample-application"
        Service     = "VNET"
        Environment = "dev"
        Criticality = "Medium"
        Compliance  = "Standard"
      }
      enable_flow_logs = false
    }
  }

  # Configuración de Subnets
  subnet_config = {
    tags = {
      Owner       = "SampleTeam"
      Service     = "SampleNetworking"
      Environment = "dev"
    }
    subnets = {
      web = {
        address_prefixes = ["10.0.1.0/24"]
        service_endpoints = ["Microsoft.Storage"]
        route_table_key = "default_routes"
        tags = { Tier = "Web" }
      }
      app = {
        address_prefixes = ["10.0.2.0/24"]
        service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
        route_table_key = "default_routes"
        tags = { Tier = "Application" }
      }
      data = {
        address_prefixes = ["10.0.3.0/24"]
        service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
        private_endpoint_network_policies_enabled = true
        route_table_key = "default_routes"
        tags = { Tier = "Data" }
      }
    }
  }

  # Configuración de Route Tables
  route_tables_config = {
    tags = {
      Owner   = "SampleTeam"
      Service = "SampleNetworking"
    }
    route_tables = {
      default_routes = {
        name = "rt-sample-default"
        routes = {
          internet = {
            address_prefix = "0.0.0.0/0"
            next_hop_type = "Internet"
          }
          internal = {
            address_prefix = "10.0.0.0/8"
            next_hop_type = "VnetLocal"
          }
        }
      }
    }
  }

  # Configuración de VNet Peerings
  vnet_peerings = {
    hub_connection = {
      remote_virtual_network_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub"
      allow_forwarded_traffic   = true
      allow_virtual_network_access = true
      allow_gateway_transit     = false
      use_remote_gateways       = false
    }
  }

  # Configuración de Private Endpoint
  endpoint_key_vault = {
    is_manual_connection = false
    name = "kv-sample-dev"
    subresource_names = ["vault"]
  }
}
```

## 📋 Requisitos

- Terraform >= 1.0.0
- Azure CLI >= 2.30.0
- Provider AzureRM >= 3.0.0

## 🏷️ Tags Obligatorios

Todos los recursos incluyen tags estándar:
- `Owner`: Propietario del recurso
- `Service`: Servicio o aplicación
- `Environment`: Ambiente (dev/test/prod)
- `Criticality`: Criticidad (Low/Medium/High/Critical)
- `Compliance`: Estándar de cumplimiento

## 🔒 Características de Seguridad

- ✅ Validaciones de entrada con Terraform validation blocks
- ✅ Prevención de uso de subnets por defecto
- ✅ Configuración mutual exclusivity en VNet peerings
- ✅ Validación de bloques CIDR
- ✅ Lifecycle rules para prevenir destrucción accidental
- ✅ Private endpoint network policies habilitadas

## 📖 Documentación Adicional

- [Guía de Uso](./docs/usage.md)
- [Troubleshooting](./docs/troubleshooting.md)
- [Módulo VNet](./Modules/vnet/README.md)
- [Módulo Subnet](./Modules/subnet/README.md)
- [Módulo VNet Peering](./Modules/vnet_peering/README.md)
- [Módulo Route Table](./Modules/route_table/README.md)