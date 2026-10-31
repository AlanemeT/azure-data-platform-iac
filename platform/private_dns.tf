resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.platform.name

  tags = local.common_tags
}

resource "azurerm_private_dns_zone" "dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = azurerm_resource_group.platform.name

  tags = local.common_tags
}

resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.platform.name

  tags = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name = "link-blob-${var.environment}"

  private_dns_zone_id = azurerm_private_dns_zone.blob.id
  virtual_network_id  = azurerm_virtual_network.platform.id

  registration_enabled = false

  tags = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dfs" {
  name = "link-dfs-${var.environment}"

  private_dns_zone_id = azurerm_private_dns_zone.dfs.id
  virtual_network_id  = azurerm_virtual_network.platform.id

  registration_enabled = false

  tags = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name = "link-keyvault-${var.environment}"

  private_dns_zone_id = azurerm_private_dns_zone.keyvault.id
  virtual_network_id  = azurerm_virtual_network.platform.id

  registration_enabled = false

  tags = local.common_tags
}