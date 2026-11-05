# ---------------------------------------------------------
# Log Analytics
# ---------------------------------------------------------

resource "azurerm_log_analytics_workspace" "platform" {
  name = "law-data-platform-${var.environment}"

  location            = var.location
  resource_group_name = var.resource_group_name

  sku               = "PerGB2018"
  retention_in_days = 30

  tags = var.tags
}


# ---------------------------------------------------------
# Data Factory Diagnostics
# ---------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "adf" {
  name = "diag-adf-${var.environment}"

  target_resource_id         = var.data_factory_id
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
# Key Vault Diagnostics
# ---------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  name = "diag-keyvault-${var.environment}"

  target_resource_id         = var.keyvault_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.platform.id

  enabled_log {
    category = "AuditEvent"
  }
}


# ---------------------------------------------------------
# Storage Diagnostics
# ---------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "datalake_blob" {
  name = "diag-datalake-blob-${var.environment}"

  target_resource_id         = var.datalake_blob_service_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.platform.id


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


# ---------------------------------------------------------
# Action Group
# ---------------------------------------------------------

resource "azurerm_monitor_action_group" "platform" {
  name = "ag-data-platform-${var.environment}"

  resource_group_name = var.resource_group_name

  short_name = "dp${var.environment}"

  email_receiver {
    name                    = "platform-ops-email"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }

  tags = var.tags
}


# ---------------------------------------------------------
# ADF Failed Pipeline Alert
# ---------------------------------------------------------

resource "azurerm_monitor_metric_alert" "adf_pipeline_failures" {
  name = "alert-adf-pipeline-failures-${var.environment}"

  resource_group_name = var.resource_group_name

  scopes = [
    var.data_factory_id
  ]

  description = "Alert when one or more Azure Data Factory pipeline runs fail."

  severity = 2

  frequency   = "PT1M"
  window_size = "PT5M"

  criteria {
    metric_namespace = "Microsoft.DataFactory/factories"
    metric_name      = "PipelineFailedRuns"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 0
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }

  tags = var.tags
}