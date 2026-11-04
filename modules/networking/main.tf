resource "azurerm_virtual_network" "platform" {
  name                = "vnet-data-platform-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = var.vnet_address_space

  tags = var.tags
}


resource "azurerm_subnet" "integration" {
  name = "snet-integration"

  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.platform.name

  address_prefixes = var.integration_subnet_prefixes
}


resource "azurerm_subnet" "private_endpoints" {
  name = "snet-private-endpoints"

  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.platform.name

  address_prefixes = var.private_endpoint_subnet_prefixes
}


# ---------------------------------------------------------
# Private DNS Zones
# ---------------------------------------------------------

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone" "dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}


# ---------------------------------------------------------
# Private DNS -> VNet Links
# ---------------------------------------------------------

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name = "link-blob-${var.environment}"

  private_dns_zone_id = azurerm_private_dns_zone.blob.id
  virtual_network_id  = azurerm_virtual_network.platform.id

  registration_enabled = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "dfs" {
  name = "link-dfs-${var.environment}"

  private_dns_zone_id = azurerm_private_dns_zone.dfs.id
  virtual_network_id  = azurerm_virtual_network.platform.id

  registration_enabled = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name = "link-keyvault-${var.environment}"

  private_dns_zone_id = azurerm_private_dns_zone.keyvault.id
  virtual_network_id  = azurerm_virtual_network.platform.id

  registration_enabled = false
}