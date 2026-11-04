output "datalake_id" {
  value = azurerm_storage_account.datalake.id
}

output "datalake_name" {
  value = azurerm_storage_account.datalake.name
}

output "blob_service_id" {
  value = "${azurerm_storage_account.datalake.id}/blobServices/default"
}