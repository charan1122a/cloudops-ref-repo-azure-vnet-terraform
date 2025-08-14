# **Módulo Terraform: Azure Subnet**

## Descripción:

Este módulo facilita la creación de subnets en Azure con configuración avanzada, incluyendo service endpoints, delegaciones, route tables y Network Security Groups. Proporciona segmentación de red por capas funcionales siguiendo las mejores prácticas del Cloud Adoption Framework.

Este módulo de Terraform para Azure Subnet realizará las siguientes acciones:

- Crear subnets segmentadas por dominio funcional (web, app, data, management)
- Configurar service endpoints para servicios de Azure
- Implementar delegaciones para servicios específicos
- Asociar route tables y Network Security Groups
- Configurar private endpoint network policies
- Aplicar tags estandarizados según governance

## Uso del Módulo:

```hcl
module "sample_subnets" {
  source = "./Samples/subnet"
  
  # Configuración básica
  project              = "SampleProject"
  environment          = "dev"
  resource_group_name  = "rg-sample-network"
  virtual_network_name = "vnet-sample-dev"
  location             = "East US"
  
  # Configuración de subnets
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
      tags = { Tier = "Data" }
    }
  }
  
  # Route table IDs
  route_table_ids = {
    default_routes = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sample/providers/Microsoft.Network/routeTables/rt-sample-default"
  }
  
  # Tags globales
  tags = {
    Owner       = "SampleTeam"
    Service     = "SampleNetworking"
    Environment = "dev"
  }
}
```

## Variables de Entrada:

| Variable | Tipo | Descripción | Requerido | Valor por Defecto |
|----------|------|-------------|-----------|-------------------|
| `project` | string | Nombre del proyecto | ✅ | "SampleProject" |
| `environment` | string | Ambiente (dev/test/prod) | ✅ | "dev" |
| `resource_group_name` | string | Nombre del resource group | ✅ | - |
| `virtual_network_name` | string | Nombre de la VNet | ✅ | - |
| `location` | string | Región de Azure | ✅ | - |
| `subnets` | map(object) | Configuración de subnets | ✅ | - |
| `route_table_ids` | map(string) | IDs de route tables | ❌ | {} |
| `tags` | map(string) | Tags globales | ❌ | {} |

## Outputs:

| Output | Descripción |
|--------|-------------|
| `subnet_ids` | Map de IDs de subnets |
| `subnet_names` | Map de nombres de subnets |

## Validaciones de Seguridad:

- ✅ Prevención de uso de subnets "default" o "GatewaySubnet"
- ✅ Validación de ambiente permitido (dev/test/prod)
- ✅ Validación de longitud del nombre del proyecto
- ✅ Verificación de route_table_key existente

## Service Endpoints Soportados:

- `Microsoft.Storage`
- `Microsoft.Sql`
- `Microsoft.KeyVault`
- `Microsoft.ServiceBus`
- `Microsoft.EventHub`
- `Microsoft.CosmosDB`

## Ejemplo con Delegaciones:

```hcl
module "app_subnets" {
  source = "./Samples/subnet"
  
  project              = "AppSample"
  environment          = "dev"
  resource_group_name  = "rg-app-sample"
  virtual_network_name = "vnet-app-sample"
  location             = "East US"
  
  subnets = {
    app_service = {
      address_prefixes = ["10.0.5.0/24"]
      delegations = {
        app_service_delegation = {
          service_name = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
      tags = { Service = "AppService" }
    }
  }
}
```

## Recursos Creados:

- `azurerm_subnet` - Subnets principales
- `azurerm_subnet_route_table_association` - Asociaciones con route tables
- `azurerm_subnet_network_security_group_association` - Asociaciones con NSGs