# ---------------------------------------------------------
# ADLS Gen2
# ---------------------------------------------------------

resource "azurerm_storage_account" "datalake" {
  name = "stdp${var.unique_suffix}${var.environment}"

  resource_group_name = var.resource_group_name
  location            = var.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  is_hns_enabled = true

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  public_network_access = "Disabled"
  network_rules {
    default_action = "Deny"
    bypass         = ["None"]
  }

  tags = var.tags
}


# ---------------------------------------------------------
# Data Lake Containers
# ---------------------------------------------------------

resource "azurerm_storage_container" "landing" {
  name                  = "landing"
  storage_account_id    = azurerm_storage_account.datalake.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "raw" {
  name                  = "raw"
  storage_account_id    = azurerm_storage_account.datalake.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "curated" {
  name                  = "curated"
  storage_account_id    = azurerm_storage_account.datalake.id
  container_access_type = "private"
}


# ---------------------------------------------------------
# Blob Private Endpoint
# ---------------------------------------------------------

resource "azurerm_private_endpoint" "datalake_blob" {
  name = "pe-datalake-blob-${var.environment}"

  location            = var.location
  resource_group_name = var.resource_group_name

  subnet_id = var.private_endpoint_subnet_id

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
      var.blob_private_dns_zone_id
    ]
  }

  tags = var.tags
}


# ---------------------------------------------------------
# DFS Private Endpoint
# ---------------------------------------------------------

resource "azurerm_private_endpoint" "datalake_dfs" {
  name = "pe-datalake-dfs-${var.environment}"

  location            = var.location
  resource_group_name = var.resource_group_name

  subnet_id = var.private_endpoint_subnet_id

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
      var.dfs_private_dns_zone_id
    ]
  }

  tags = var.tags
}