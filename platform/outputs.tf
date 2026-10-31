output "resource_group_name" {
  description = "Data platform resource group"
  value       = azurerm_resource_group.platform.name
}

output "vnet_name" {
  description = "Data platform virtual network"
  value       = azurerm_virtual_network.platform.name
}

output "datalake_name" {
  description = "ADLS Gen2 storage account"
  value       = azurerm_storage_account.datalake.name
}

output "key_vault_name" {
  description = "Azure Key Vault"
  value       = azurerm_key_vault.platform.name
}

output "data_factory_name" {
  description = "Azure Data Factory"
  value       = azurerm_data_factory.platform.name
}

output "data_factory_principal_id" {
  description = "Managed identity principal ID for Data Factory"
  value       = azurerm_data_factory.platform.identity[0].principal_id
}