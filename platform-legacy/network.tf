resource "azurerm_virtual_network" "platform" {
  name                = "vnet-data-platform-${var.environment}"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name

  address_space = [
    "10.20.0.0/16"
  ]

  tags = local.common_tags

}

resource "azurerm_subnet" "integration" {
  name                 = "snet-integration"
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.platform.name

  address_prefixes = [
    "10.20.1.0/24"
  ]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.platform.name

  address_prefixes = [
    "10.20.2.0/24"
  ]
}

