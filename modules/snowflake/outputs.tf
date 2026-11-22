output "database_name" {
  value = snowflake_database.platform.name
}

output "raw_schema_name" {
  value = snowflake_schema.raw.name
}

output "curated_schema_name" {
  value = snowflake_schema.curated.name
}

output "warehouse_name" {
  value = snowflake_warehouse.platform.name
}

output "engineer_role_name" {
  value = snowflake_account_role.engineer.name
}

output "reader_role_name" {
  value = snowflake_account_role.reader.name
}

output "azure_storage_integration_name" {
  value = snowflake_storage_integration_azure.azure_ingestion.name
}

output "azure_external_stage_name" {
  value = snowflake_stage_external_azure.azure_ingestion.name
}

output "azure_consent_url" {
  value     = snowflake_storage_integration_azure.azure_ingestion.describe_output[0].consent_url
  sensitive = true
}

output "azure_multi_tenant_app_name" {
  value = snowflake_storage_integration_azure.azure_ingestion.describe_output[0].multi_tenant_app_name
}