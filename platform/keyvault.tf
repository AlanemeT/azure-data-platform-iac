resource "azurerm_key_vault" "platform" {
  name = "kv-dp-${local.unique_suffix}-${var.environment}"

  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name

  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name  = "standard"

  rbac_authorization_enabled = true

  soft_delete_retention_days    = 7
  purge_protection_enabled      = false
  public_network_access_enabled = false

  tags = local.common_tags
}