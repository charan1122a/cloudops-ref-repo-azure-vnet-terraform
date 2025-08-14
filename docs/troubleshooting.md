# Troubleshooting Guide

## 🚨 Errores Comunes

### Error: Address Space Overlap
```
Error: creating Virtual Network Peering: network.VirtualNetworkPeeringsClient#CreateOrUpdate: 
Failure responding to request: StatusCode=400 -- Original Error: Code="AddressSpaceOverlap"
```

**Solución:**
- Verificar que los address spaces no se solapen
- Usar herramientas de planificación de IP
- Documentar rangos CIDR utilizados

### Error: Route Table Association
```
Error: creating Subnet Route Table Association: network.SubnetsClient#CreateOrUpdate: 
Failure responding to request: StatusCode=400 -- Original Error: Code="RouteTableNotFound"
```

**Solución:**
```hcl
# Asegurar dependencias explícitas
resource "azurerm_subnet_route_table_association" "main" {
  subnet_id      = azurerm_subnet.main.id
  route_table_id = azurerm_route_table.main.id
  
  depends_on = [
    azurerm_route_table.main,
    azurerm_subnet.main
  ]
}
```

### Error: NSG Rules Conflict
```
Error: creating Network Security Rule: network.SecurityRulesClient#CreateOrUpdate: 
Failure responding to request: StatusCode=400 -- Original Error: Code="SecurityRulePriorityConflict"
```

**Solución:**
- Usar prioridades únicas (100-4096)
- Implementar naming convention para prioridades
- Documentar reglas existentes

## 🔧 Comandos de Diagnóstico

### Verificar Conectividad
```bash
# Test de conectividad entre subnets
az network watcher test-connectivity \
  --source-resource /subscriptions/.../virtualMachines/vm1 \
  --dest-resource /subscriptions/.../virtualMachines/vm2 \
  --dest-port 443

# Verificar rutas efectivas
az network nic show-effective-route-table \
  --resource-group rg-network \
  --name vm-nic
```

### Validar Configuración
```bash
# Validar Terraform
terraform validate
terraform plan -detailed-exitcode

# Verificar formato
terraform fmt -check -recursive

# Linting
tflint --recursive

# Security scan
checkov -d . --framework terraform
```

## 📋 Checklist de Validación

### Pre-deployment
- [ ] Address spaces documentados
- [ ] NSG rules validadas
- [ ] Route tables configuradas
- [ ] Tags aplicados correctamente
- [ ] Naming convention seguida

### Post-deployment
- [ ] Conectividad verificada
- [ ] Flow logs funcionando
- [ ] Monitoring configurado
- [ ] Backup de configuración
- [ ] Documentación actualizada

## 🔍 Logs y Monitoreo

### Habilitar Diagnostic Logs
```hcl
resource "azurerm_monitor_diagnostic_setting" "vnet" {
  name               = "diag-vnet-${var.environment}"
  target_resource_id = azurerm_virtual_network.main.id
  
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  
  enabled_log {
    category = "VMProtectionAlerts"
  }
  
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
```

### Queries Útiles (KQL)
```kql
// Top 10 IPs con más tráfico
AzureNetworkAnalytics_CL
| where TimeGenerated > ago(1h)
| summarize TotalBytes = sum(FlowCount_d) by SrcIP_s
| top 10 by TotalBytes

// Conexiones bloqueadas por NSG
AzureNetworkAnalytics_CL
| where FlowStatus_s == "D"
| summarize BlockedConnections = count() by NSGRule_s
```