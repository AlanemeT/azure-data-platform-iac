# ---------------------------------------------------------
# Azure Data Factory diagnostics
# ---------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "adf" {
  name = "diag-adf-${var.environment}"

  target_resource_id         = azurerm_data_factory.platform.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.platform.id

  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "PipelineRuns"
  }

  enabled_log {
    category = "ActivityRuns"
  }

  enabled_log {
    category = "TriggerRuns"
  }
}


# ---------------------------------------------------------
# Azure Key Vault diagnostics
# ---------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  name = "diag-keyvault-${var.environment}"

  target_resource_id         = azurerm_key_vault.platform.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.platform.id

  enabled_log {
    category = "AuditEvent"
  }
}


# ---------------------------------------------------------
# ADLS Gen2 Blob diagnostics
# ---------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "datalake_blob" {
  name = "diag-datalake-blob-${var.environment}"

  target_resource_id         = local.datalake_blob_service_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.platform.id

  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }
}