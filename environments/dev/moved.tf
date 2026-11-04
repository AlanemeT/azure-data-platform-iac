# =========================================================
# NETWORKING
# =========================================================

moved {
  from = azurerm_virtual_network.platform
  to   = module.networking.azurerm_virtual_network.platform
}

moved {
  from = azurerm_subnet.integration
  to   = module.networking.azurerm_subnet.integration
}

moved {
  from = azurerm_subnet.private_endpoints
  to   = module.networking.azurerm_subnet.private_endpoints
}

moved {
  from = azurerm_private_dns_zone.blob
  to   = module.networking.azurerm_private_dns_zone.blob
}

moved {
  from = azurerm_private_dns_zone.dfs
  to   = module.networking.azurerm_private_dns_zone.dfs
}

moved {
  from = azurerm_private_dns_zone.keyvault
  to   = module.networking.azurerm_private_dns_zone.keyvault
}

moved {
  from = azurerm_private_dns_zone_virtual_network_link.blob
  to   = module.networking.azurerm_private_dns_zone_virtual_network_link.blob
}

moved {
  from = azurerm_private_dns_zone_virtual_network_link.dfs
  to   = module.networking.azurerm_private_dns_zone_virtual_network_link.dfs
}

moved {
  from = azurerm_private_dns_zone_virtual_network_link.keyvault
  to   = module.networking.azurerm_private_dns_zone_virtual_network_link.keyvault
}


# =========================================================
# STORAGE
# =========================================================

moved {
  from = azurerm_storage_account.datalake
  to   = module.storage.azurerm_storage_account.datalake
}

moved {
  from = azurerm_storage_container.landing
  to   = module.storage.azurerm_storage_container.landing
}

moved {
  from = azurerm_storage_container.raw
  to   = module.storage.azurerm_storage_container.raw
}

moved {
  from = azurerm_storage_container.curated
  to   = module.storage.azurerm_storage_container.curated
}

moved {
  from = azurerm_private_endpoint.datalake_blob
  to   = module.storage.azurerm_private_endpoint.datalake_blob
}

moved {
  from = azurerm_private_endpoint.datalake_dfs
  to   = module.storage.azurerm_private_endpoint.datalake_dfs
}


# =========================================================
# KEY VAULT
# =========================================================

moved {
  from = azurerm_key_vault.platform
  to   = module.keyvault.azurerm_key_vault.platform
}

moved {
  from = azurerm_private_endpoint.keyvault
  to   = module.keyvault.azurerm_private_endpoint.keyvault
}


# =========================================================
# DATA FACTORY
# =========================================================

moved {
  from = azurerm_data_factory.platform
  to   = module.datafactory.azurerm_data_factory.platform
}

moved {
  from = azurerm_data_factory_integration_runtime_azure.managed
  to   = module.datafactory.azurerm_data_factory_integration_runtime_azure.managed
}

moved {
  from = azurerm_data_factory_managed_private_endpoint.datalake_blob
  to   = module.datafactory.azurerm_data_factory_managed_private_endpoint.datalake_blob
}

moved {
  from = azurerm_data_factory_managed_private_endpoint.datalake_dfs
  to   = module.datafactory.azurerm_data_factory_managed_private_endpoint.datalake_dfs
}

moved {
  from = azurerm_data_factory_managed_private_endpoint.keyvault
  to   = module.datafactory.azurerm_data_factory_managed_private_endpoint.keyvault
}


# =========================================================
# MONITORING
# =========================================================

moved {
  from = azurerm_log_analytics_workspace.platform
  to   = module.monitoring.azurerm_log_analytics_workspace.platform
}

moved {
  from = azurerm_monitor_diagnostic_setting.adf
  to   = module.monitoring.azurerm_monitor_diagnostic_setting.adf
}

moved {
  from = azurerm_monitor_diagnostic_setting.keyvault
  to   = module.monitoring.azurerm_monitor_diagnostic_setting.keyvault
}

moved {
  from = azurerm_monitor_diagnostic_setting.datalake_blob
  to   = module.monitoring.azurerm_monitor_diagnostic_setting.datalake_blob
}

moved {
  from = azurerm_monitor_action_group.platform
  to   = module.monitoring.azurerm_monitor_action_group.platform
}

moved {
  from = azurerm_monitor_metric_alert.adf_pipeline_failures
  to   = module.monitoring.azurerm_monitor_metric_alert.adf_pipeline_failures
}