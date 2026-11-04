resource "azurerm_key_vault" "platform" {
  name = "kv-dp-${var.unique_suffix}-${var.environment}"

  location            = var.location
  resource_group_name = var.resource_group_name

  tenant_id = var.tenant_id
  sku_name  = "standard"

  rbac_authorization_enabled = true

  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  public_network_access_enabled = false

  tags = var.tags
}


resource "azurerm_private_endpoint" "keyvault" {
  name = "pe-keyvault-${var.environment}"

  location            = var.location
  resource_group_name = var.resource_group_name

  subnet_id = var.private_endpoint_subnet_id

  private_service_connection {
    name = "psc-keyvault-${var.environment}"

    private_connection_resource_id = azurerm_key_vault.platform.id

    subresource_names = [
      "vault"
    ]

    is_manual_connection = false
  }

  private_dns_zone_group {
    name = "default"

    private_dns_zone_ids = [
      var.keyvault_private_dns_zone_id
    ]
  }

  tags = var.tags
}