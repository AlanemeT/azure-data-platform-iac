# =========================================================
# Networking
# =========================================================

module "networking" {
  source = "../../modules/networking"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location
  environment         = var.environment

  vnet_address_space = var.vnet_address_space

  integration_subnet_prefixes = var.integration_subnet_prefixes

  private_endpoint_subnet_prefixes = var.private_endpoint_subnet_prefixes

  tags = local.common_tags
}


# =========================================================
# Storage / ADLS
# =========================================================

module "storage" {
  source = "../../modules/storage"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location

  environment   = var.environment
  unique_suffix = local.unique_suffix

  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id

  blob_private_dns_zone_id = module.networking.blob_private_dns_zone_id

  dfs_private_dns_zone_id = module.networking.dfs_private_dns_zone_id

  tags = local.common_tags
}


# =========================================================
# Key Vault
# =========================================================

module "keyvault" {
  source = "../../modules/keyvault"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location

  environment   = var.environment
  unique_suffix = local.unique_suffix

  tenant_id = data.azurerm_client_config.current.tenant_id

  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id

  keyvault_private_dns_zone_id = module.networking.keyvault_private_dns_zone_id

  tags = local.common_tags
}


# =========================================================
# Azure Data Factory
# =========================================================

module "datafactory" {
  source = "../../modules/datafactory"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location

  environment   = var.environment
  unique_suffix = local.unique_suffix

  datalake_id = module.storage.datalake_id

  keyvault_id = module.keyvault.keyvault_id

  tags = local.common_tags
}


# =========================================================
# Monitoring / Observability
# =========================================================

module "monitoring" {
  source = "../../modules/monitoring"

  resource_group_name = azurerm_resource_group.platform.name
  location            = azurerm_resource_group.platform.location

  environment = var.environment

  data_factory_id = module.datafactory.data_factory_id

  datalake_blob_service_id = module.storage.blob_service_id

  keyvault_id = module.keyvault.keyvault_id

  alert_email = var.alert_email

  tags = local.common_tags
}