data "azurerm_client_config" "current" {}

locals {
  unique_suffix = substr(
    replace(var.subscription_id, "-", ""),
    0,
    6
  )

  common_tags = {
    environment = var.environment
    project     = "azure-data-platform"
    managed_by  = "terraform"
  }

  datalake_blob_service_id = "${azurerm_storage_account.datalake.id}/blobServices/default"

}