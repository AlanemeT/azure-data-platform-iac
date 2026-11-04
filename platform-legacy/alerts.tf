resource "azurerm_monitor_action_group" "platform" {
  name = "ag-data-platform-${var.environment}"

  resource_group_name = azurerm_resource_group.platform.name

  short_name = "dp${var.environment}"

  email_receiver {
    name                    = "platform-ops-email"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }

  tags = local.common_tags
}

resource "azurerm_monitor_metric_alert" "adf_pipeline_failures" {
  name = "alert-adf-pipeline-failures-${var.environment}"

  resource_group_name = azurerm_resource_group.platform.name

  scopes = [
    azurerm_data_factory.platform.id
  ]

  description = "Alert when one or more Azure Data Factory pipeline runs fail."

  severity = 2

  frequency   = "PT1M"
  window_size = "PT5M"

  criteria {
    metric_namespace = "Microsoft.DataFactory/factories"

    metric_name = "PipelineFailedRuns"

    aggregation = "Total"

    operator = "GreaterThan"

    threshold = 0
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }

  tags = local.common_tags
}