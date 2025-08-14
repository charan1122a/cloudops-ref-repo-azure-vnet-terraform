# **Módulo Terraform: Azure Virtual Network**

## Descripción:

Este módulo facilita la creación de Virtual Networks (VNets) en Azure con configuración avanzada, incluyendo DNS personalizado, DDoS Protection, Flow Logs y peerings. Proporciona una base sólida para arquitecturas de red seguras y escalables.

Este módulo de Terraform para Azure VNet realizará las siguientes acciones:

- Crear una VNet con el address space especificado
- Configurar servidores DNS personalizados
- Implementar DDoS Protection Plan (opcional)
- Configurar Flow Logs para monitoreo
- Crear VNet peerings con configuración controlada
- Aplicar tags estandarizados según governance

## Uso del Módulo:

```hcl
module "sample_vnet" {
  source = "./Samples/vnet"
  
  # Configuración básica
  project             = "SampleProject"
  environment         = "dev"
  resource_group_name = "rg-sample-network"
  location            = "East US"
  
  # Configuración de red
  address_space = ["10.0.0.0/16"]
  dns_servers   = ["10.0.0.4", "10.0.0.5"]
  
  # Tags
  tags = {
    Owner       = "SampleTeam"
    Service     = "SampleNetworking"
    Criticality = "Medium"
    Compliance  = "Standard"
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
| `address_space` | list(string) | Espacios de direcciones CIDR | ✅ | - |
| `dns_servers` | list(string) | Servidores DNS personalizados | ❌ | [] |
| `tags` | map(string) | Tags adicionales | ❌ | {} |

## Outputs:

| Output | Descripción |
|--------|-------------|
| `vnet_id` | ID de la Virtual Network |
| `vnet_name` | Nombre de la Virtual Network |
| `address_space` | Espacios de direcciones configurados |

## Validaciones de Seguridad:

- ✅ Validación de longitud del nombre del proyecto (1-50 caracteres)
- ✅ Validación de ambiente permitido (dev/test/prod)
- ✅ Validación de bloques CIDR válidos
- ✅ Lifecycle rule para prevenir destrucción accidental

## Ejemplo Mínimo:

```hcl
module "basic_vnet" {
  source = "./Samples/vnet"
  
  project             = "BasicSample"
  environment         = "dev"
  resource_group_name = "rg-basic-sample"
  location            = "East US"
  address_space       = ["10.1.0.0/16"]
  
  tags = {
    Owner = "DevTeam"
    Service = "BasicApp"
  }
}
```

## Recursos Creados:

- `azurerm_virtual_network` - Virtual Network principal
- `azurerm_virtual_network_peering` - Peerings (si se configuran)