# **Módulo Terraform: Azure Route Table**

## Descripción:

Este módulo facilita la creación de tablas de rutas en Azure con rutas personalizadas y configuración avanzada. Permite controlar el flujo de tráfico de red mediante rutas definidas por el usuario (UDR) con soporte para múltiples tipos de next hop.

Este módulo de Terraform para Azure Route Table realizará las siguientes acciones:

- Crear route tables con rutas personalizadas
- Configurar múltiples tipos de next hop (Internet, VnetLocal, VirtualAppliance, etc.)
- Implementar deshabilitación de propagación BGP opcional
- Aplicar naming conventions estándar
- Configurar tags automáticos según governance

## Uso del Módulo:

```hcl
module "sample_route_tables" {
  source = "./Samples/route_table"
  
  # Configuración básica
  project             = "SampleProject"
  environment         = "dev"
  resource_group_name = "rg-sample-network"
  location            = "East US"
  
  # Configuración de route tables
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
    
    firewall_routes = {
      name = "rt-sample-firewall"
      disable_bgp_route_propagation = true
      routes = {
        firewall = {
          address_prefix = "0.0.0.0/0"
          next_hop_type = "VirtualAppliance"
          next_hop_in_ip_address = "10.0.1.4"
        }
      }
    }
  }
}
```

## Variables de Entrada:

| Variable | Tipo | Descripción | Requerido | Valor por Defecto |
|----------|------|-------------|-----------|-------------------|
| `project` | string | Nombre del proyecto | ✅ | "SampleProject" |
| `environment` | string | Ambiente (dev/test/prod) | ✅ | "dev" |
| `resource_group_name` | string | Nombre del resource group | ✅ | - |
| `location` | string | Región de Azure | ✅ | - |
| `route_tables` | map(object) | Configuración de route tables | ✅ | - |

## Outputs:

| Output | Descripción |
|--------|-------------|
| `route_table_ids` | Map de IDs de route tables |
| `route_table_names` | Map de nombres de route tables |

## Validaciones de Seguridad:

- ✅ Validación de `next_hop_type` válidos
- ✅ Validación de ambiente permitido (dev/test/prod)
- ✅ Validación de longitud del nombre del proyecto (1-50 caracteres)

## Next Hop Types Soportados:

| Type | Descripción | Requiere IP |
|------|-------------|-------------|
| `Internet` | Tráfico a Internet | ❌ |
| `VnetLocal` | Tráfico local en VNet | ❌ |
| `VirtualAppliance` | NVA/Firewall | ✅ |
| `VirtualNetworkGateway` | VPN/ExpressRoute Gateway | ❌ |
| `None` | Drop traffic | ❌ |

## Ejemplo Hub-Spoke con Firewall:

```hcl
module "hub_routes" {
  source = "./Samples/route_table"
  
  project             = "HubSpoke"
  environment         = "prod"
  resource_group_name = "rg-network-prod"
  location            = "East US"
  
  route_tables = {
    spoke_routes = {
      name = "rt-spoke-prod"
      routes = {
        # Todo el tráfico por firewall
        default = {
          address_prefix = "0.0.0.0/0"
          next_hop_type = "VirtualAppliance"
          next_hop_in_ip_address = "10.0.1.4"
        }
        
        # Excepción para servicios de Azure
        azure_services = {
          address_prefix = "AzureCloud"
          next_hop_type = "Internet"
        }
      }
    }
  }
}
```

## Ejemplo DMZ con Internet Directo:

```hcl
module "dmz_routes" {
  source = "./Samples/route_table"
  
  project             = "DMZ"
  environment         = "prod"
  resource_group_name = "rg-dmz-prod"
  location            = "East US"
  
  route_tables = {
    dmz_routes = {
      name = "rt-dmz-prod"
      routes = {
        # Internet directo para DMZ
        internet = {
          address_prefix = "0.0.0.0/0"
          next_hop_type = "Internet"
        }
        
        # Tráfico interno bloqueado
        internal_block = {
          address_prefix = "10.0.0.0/8"
          next_hop_type = "None"
        }
      }
    }
  }
}
```

## Recursos Creados:

- `azurerm_route_table` - Route table principal
- `azurerm_route` - Rutas individuales