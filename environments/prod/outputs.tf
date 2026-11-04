output "resource_group_name" {
  value = azurerm_resource_group.platform.name
}

output "vnet_name" {
  value = module.networking.vnet_name
}

output "datalake_name" {
  value = module.storage.datalake_name
}

output "keyvault_name" {
  value = module.keyvault.keyvault_name
}

output "data_factory_name" {
  value = module.datafactory.data_factory_name
}

output "data_factory_principal_id" {
  value = module.datafactory.principal_id
}

output "log_analytics_workspace_name" {
  value = module.monitoring.log_analytics_workspace_name
}