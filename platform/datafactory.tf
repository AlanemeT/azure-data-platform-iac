resource "azurerm_data_factory" "platform" {
  name = "adf-dp-${local.unique_suffix}-${var.environment}"

  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name

  managed_virtual_network_enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}