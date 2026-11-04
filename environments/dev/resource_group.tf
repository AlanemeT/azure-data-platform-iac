resource "azurerm_resource_group" "platform" {
  name     = "rg-data-platform-${var.environment}"
  location = var.location

  tags = local.common_tags
}