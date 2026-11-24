output "storage_account_id" {
  value = azurerm_storage_account.snowflake_ingestion.id
}

output "storage_account_name" {
  value = azurerm_storage_account.snowflake_ingestion.name
}

output "container_name" {
  value = azurerm_storage_container.ingestion.name
}

output "stage_url" {
  value = "azure://${azurerm_storage_account.snowflake_ingestion.name}.blob.core.windows.net/${azurerm_storage_container.ingestion.name}/incoming/"
}

output "snowpipe_queue_id" {
  value = azurerm_storage_queue.snowpipe.id
}

output "snowpipe_queue_url" {
  value = azurerm_storage_queue.snowpipe.url
}