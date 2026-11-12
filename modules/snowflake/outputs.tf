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