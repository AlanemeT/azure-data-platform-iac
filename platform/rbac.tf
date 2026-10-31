resource "azurerm_role_assignment" "adf_storage_data_contributor" {
  scope = azurerm_storage_account.datalake.id

  role_definition_name = "Storage Blob Data Contributor"

  principal_id = azurerm_data_factory.platform.identity[0].principal_id

  principal_type = "ServicePrincipal"
}

resource "azurerm_role_assignment" "adf_keyvault_secrets_user" {
  scope = azurerm_key_vault.platform.id

  role_definition_name = "Key Vault Secrets User"

  principal_id = azurerm_data_factory.platform.identity[0].principal_id

  principal_type = "ServicePrincipal"
}