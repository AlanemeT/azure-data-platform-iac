output "vnet_id" {
  value = azurerm_virtual_network.platform.id
}

output "vnet_name" {
  value = azurerm_virtual_network.platform.name
}

output "integration_subnet_id" {
  value = azurerm_subnet.integration.id
}

output "private_endpoint_subnet_id" {
  value = azurerm_subnet.private_endpoints.id
}

output "blob_private_dns_zone_id" {
  value = azurerm_private_dns_zone.blob.id
}

output "dfs_private_dns_zone_id" {
  value = azurerm_private_dns_zone.dfs.id
}

output "keyvault_private_dns_zone_id" {
  value = azurerm_private_dns_zone.keyvault.id
}