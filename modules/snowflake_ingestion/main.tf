resource "azurerm_storage_account" "snowflake_ingestion" {
  name = "stsf${var.unique_suffix}${var.environment}"

  resource_group_name = var.resource_group_name
  location            = var.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"

  allow_nested_items_to_be_public = false

  # DEV/TRIAL exception:
  # Snowflake trial accounts do not support outbound private connectivity.
  public_network_access_enabled = true

  tags = merge(
    var.tags,
    {
      purpose = "snowflake-ingestion-lab"
    }
  )
}


resource "azurerm_storage_container" "ingestion" {
  name = "snowflake-ingest"

  storage_account_id = azurerm_storage_account.snowflake_ingestion.id

  container_access_type = "private"
}