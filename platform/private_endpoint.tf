resource "azurerm_private_endpoint" "datalake_blob" {
  name = "pe-datalake-blob-${var.environment}"

  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name

  subnet_id = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name = "psc-datalake-blob-${var.environment}"

    private_connection_resource_id = azurerm_storage_account.datalake.id

    subresource_names = [
      "blob"
    ]

    is_manual_connection = false
  }

  private_dns_zone_group {
    name = "default"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.blob.id
    ]
  }

  tags = local.common_tags
}

resource "azurerm_private_endpoint" "datalake_dfs" {
  name = "pe-datalake-dfs-${var.environment}"

  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name

  subnet_id = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name = "psc-datalake-dfs-${var.environment}"

    private_connection_resource_id = azurerm_storage_account.datalake.id

    subresource_names = [
      "dfs"
    ]

    is_manual_connection = false
  }

  private_dns_zone_group {
    name = "default"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.dfs.id
    ]
  }
  tags = local.common_tags
}

resource "azurerm_private_endpoint" "keyvault" {
  name = "pe-keyvault-${var.environment}"

  location            = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name

  subnet_id = azurerm_subnet.private_endpoints.id

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
      azurerm_private_dns_zone.keyvault.id
    ]
  }

  tags = local.common_tags
}



