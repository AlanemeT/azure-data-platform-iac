resource "azurerm_role_assignment" "adf_storage_data_contributor" {
  scope = module.storage.datalake_id

  role_definition_name = "Storage Blob Data Contributor"

  principal_id = module.datafactory.principal_id

  principal_type = "ServicePrincipal"
}


resource "azurerm_role_assignment" "adf_keyvault_secrets_user" {
  scope = module.keyvault.keyvault_id

  role_definition_name = "Key Vault Secrets User"

  principal_id = module.datafactory.principal_id

  principal_type = "ServicePrincipal"
}