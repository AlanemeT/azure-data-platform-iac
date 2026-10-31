resource "azurerm_log_analytics_workspace" "platform" {
  name                = "law-data-platform-${var.environment}"
  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name

  sku               = "PerGB2018"
  retention_in_days = 30

  tags = local.common_tags
}