resource "azurerm_data_factory_integration_runtime_azure" "managed" {
  name = "ir-managed-${var.environment}"

  data_factory_id = azurerm_data_factory.platform.id

  location = azurerm_resource_group.platform.location

  virtual_network_enabled = true

  description = "Azure Integration Runtime deployed inside the ADF managed virtual network"
}

resource "azurerm_data_factory_managed_private_endpoint" "datalake_blob" {
  name = "mpe-datalake-blob"

  data_factory_id = azurerm_data_factory.platform.id

  target_resource_id = azurerm_storage_account.datalake.id

  subresource_name = "blob"
}

resource "azurerm_data_factory_managed_private_endpoint" "datalake_dfs" {
  name = "mpe-datalake-dfs"

  data_factory_id = azurerm_data_factory.platform.id

  target_resource_id = azurerm_storage_account.datalake.id

  subresource_name = "dfs"
}

resource "azurerm_data_factory_managed_private_endpoint" "keyvault" {
  name = "mpe-keyvault"

  data_factory_id = azurerm_data_factory.platform.id

  target_resource_id = azurerm_key_vault.platform.id

  subresource_name = "vault"
}