# **Módulo Terraform: Azure VNet Peering**

## Descripción:

Este módulo facilita la creación de peerings entre Virtual Networks en Azure con configuración de tráfico controlada. Permite conectar VNets de manera segura y eficiente, soportando topologías Hub-Spoke y Mesh con control granular de tráfico.

Este módulo de Terraform para Azure VNet Peering realizará las siguientes acciones:

- Crear peerings bidireccionales entre VNets
- Configurar control de tráfico granular
- Implementar gateway transit y remote gateways
- Validar configuraciones mutuamente exclusivas
- Aplicar naming conventions estándar

## Uso del Módulo:

```hcl
module "sample_peering" {
  source = "./Samples/vnet_peering"
  
  # Configuración básica
  resource_group_name  = "rg-sample-network"
  virtual_network_name = "vnet-sample-dev"
  project              = "SampleProject"
  environment          = "dev"
  
  # Configuración de peerings
  peerings = {
    hub_connection = {
      remote_virtual_network_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub/providers/Microsoft.Network/virtualNetworks/vnet-hub"
      allow_forwarded_traffic   = true
      allow_virtual_network_access = true
      allow_gateway_transit     = false
      use_remote_gateways       = false
    }
    spoke_connection = {
      remote_virtual_network_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-spoke/providers/Microsoft.Network/virtualNetworks/vnet-spoke"
      allow_forwarded_traffic   = false
      allow_virtual_network_access = true
      allow_gateway_transit     = true
      use_remote_gateways       = false
    }
  }
}
```

## Variables de Entrada:

| Variable | Tipo | Descripción | Requerido | Valor por Defecto |
|----------|------|-------------|-----------|-------------------|
| `resource_group_name` | string | Nombre del resource group | ✅ | - |
| `virtual_network_name` | string | Nombre de la VNet local | ✅ | - |
| `project` | string | Nombre del proyecto | ✅ | "SampleProject" |
| `environment` | string | Ambiente (dev/test/prod) | ✅ | "dev" |
| `peerings` | map(object) | Configuración de peerings | ✅ | - |

## Outputs:

| Output | Descripción |
|--------|-------------|
| `peering_ids` | Map de IDs de peerings |
| `peering_names` | Map de nombres de peerings |

## Validaciones de Seguridad:

- ✅ Validación mutual exclusivity entre `allow_gateway_transit` y `use_remote_gateways`
- ✅ Validación de longitud del nombre del proyecto (1-50 caracteres)
- ✅ Validación de ambiente permitido (dev/test/prod)
- ✅ Lifecycle rule para prevenir destrucción accidental

## Topologías Soportadas:

### Hub-Spoke
```hcl
# Hub VNet
module "hub_peering" {
  source = "./Samples/vnet_peering"
  
  virtual_network_name = "vnet-hub-prod"
  peerings = {
    spoke1 = {
      remote_virtual_network_id = "/subscriptions/.../vnet-spoke1-prod"
      allow_gateway_transit     = true
      use_remote_gateways       = false
    }
  }
}

# Spoke VNet
module "spoke_peering" {
  source = "./Samples/vnet_peering"
  
  virtual_network_name = "vnet-spoke1-prod"
  peerings = {
    hub = {
      remote_virtual_network_id = "/subscriptions/.../vnet-hub-prod"
      allow_gateway_transit     = false
      use_remote_gateways       = true
    }
  }
}
```

### Mesh (Full Connectivity)
```hcl
module "mesh_peering" {
  source = "./Samples/vnet_peering"
  
  virtual_network_name = "vnet-app1-prod"
  peerings = {
    app2 = {
      remote_virtual_network_id = "/subscriptions/.../vnet-app2-prod"
      allow_forwarded_traffic   = true
    }
    app3 = {
      remote_virtual_network_id = "/subscriptions/.../vnet-app3-prod"
      allow_forwarded_traffic   = true
    }
  }
}
```

## Consideraciones Importantes:

- Los peerings son unidireccionales, crear en ambas VNets
- `use_remote_gateways` requiere que la VNet remota tenga `allow_gateway_transit = true`
- No se puede usar `allow_gateway_transit` y `use_remote_gateways` simultáneamente
- Los address spaces no pueden solaparse

## Recursos Creados:

- `azurerm_virtual_network_peering` - Peering entre VNets