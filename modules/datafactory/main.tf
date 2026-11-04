# ---------------------------------------------------------
# Azure Data Factory
# ---------------------------------------------------------

resource "azurerm_data_factory" "platform" {
  name = "adf-dp-${var.unique_suffix}-${var.environment}"

  location            = var.location
  resource_group_name = var.resource_group_name

  managed_virtual_network_enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}


# ---------------------------------------------------------
# Managed Azure Integration Runtime
# ---------------------------------------------------------

resource "azurerm_data_factory_integration_runtime_azure" "managed" {
  name = "ir-managed-${var.environment}"

  data_factory_id = azurerm_data_factory.platform.id

  location = var.location

  virtual_network_enabled = true

  description = "Azure Integration Runtime deployed inside the ADF managed virtual network"
}


# ---------------------------------------------------------
# Managed Private Endpoint -> Storage Blob
# ---------------------------------------------------------

resource "azurerm_data_factory_managed_private_endpoint" "datalake_blob" {
  name = "mpe-datalake-blob"

  data_factory_id = azurerm_data_factory.platform.id

  target_resource_id = var.datalake_id

  subresource_name = "blob"
}


# ---------------------------------------------------------
# Managed Private Endpoint -> Storage DFS
# ---------------------------------------------------------

resource "azurerm_data_factory_managed_private_endpoint" "datalake_dfs" {
  name = "mpe-datalake-dfs"

  data_factory_id = azurerm_data_factory.platform.id

  target_resource_id = var.datalake_id

  subresource_name = "dfs"
}


# ---------------------------------------------------------
# Managed Private Endpoint -> Key Vault
# ---------------------------------------------------------

resource "azurerm_data_factory_managed_private_endpoint" "keyvault" {
  name = "mpe-keyvault"

  data_factory_id = azurerm_data_factory.platform.id

  target_resource_id = var.keyvault_id

  subresource_name = "vault"
}