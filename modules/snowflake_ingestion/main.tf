# Dev ingestion lab uses public connectivity for ADF and Snowflake.
# Containers are private and data access requires authentication.
# TODO: Restrict storage networking when approved access paths are configured.
#trivy:ignore:azure-storage-default-action-deny
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

# ---------------------------------------------------------
# Snowpipe notification queue
# ---------------------------------------------------------

resource "azurerm_storage_queue" "snowpipe" {
  name = "snowpipe-events"

  storage_account_id = azurerm_storage_account.snowflake_ingestion.id
}

resource "azurerm_eventgrid_system_topic" "snowpipe" {
  name = "egst-snowpipe-${var.environment}"

  location            = var.location
  resource_group_name = var.resource_group_name

  source_resource_id = azurerm_storage_account.snowflake_ingestion.id

  topic_type = "Microsoft.Storage.StorageAccounts"

  tags = var.tags
}

resource "azurerm_eventgrid_system_topic_event_subscription" "snowpipe" {
  name = "evsub-snowpipe-${var.environment}"

  system_topic = azurerm_eventgrid_system_topic.snowpipe.name

  resource_group_name = var.resource_group_name

  included_event_types = [
    "Microsoft.Storage.BlobCreated"
  ]

  subject_filter {
    subject_begins_with = "/blobServices/default/containers/${azurerm_storage_container.ingestion.name}/blobs/incoming/customers/"
    case_sensitive      = false
  }

  storage_queue_endpoint {
    storage_account_id = azurerm_storage_account.snowflake_ingestion.id

    queue_name = azurerm_storage_queue.snowpipe.name

    queue_message_time_to_live_in_seconds = 86400
  }

  retry_policy {
    max_delivery_attempts = 30
    event_time_to_live    = 1440
  }
}