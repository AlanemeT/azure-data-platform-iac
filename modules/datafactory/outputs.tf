output "data_factory_id" {
  value = azurerm_data_factory.platform.id
}

output "data_factory_name" {
  value = azurerm_data_factory.platform.name
}

output "principal_id" {
  value = azurerm_data_factory.platform.identity[0].principal_id
}