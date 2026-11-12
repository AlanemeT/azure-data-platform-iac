locals {
  environment_upper = upper(var.environment)

  database_name  = "DATA_PLATFORM_${local.environment_upper}"
  warehouse_name = "DATA_PLATFORM_WH_${local.environment_upper}"

  engineer_role_name = "DATA_PLATFORM_ENGINEER_${local.environment_upper}"
  reader_role_name   = "DATA_PLATFORM_READER_${local.environment_upper}"
}

resource "snowflake_database" "platform" {
  name = local.database_name

  comment = "Data platform database managed by Terraform"
}

resource "snowflake_schema" "raw" {
  database = snowflake_database.platform.name
  name     = "RAW"

  comment = "Raw ingested data"
}


resource "snowflake_schema" "curated" {
  database = snowflake_database.platform.name
  name     = "CURATED"

  comment = "Validated and transformed analytics-ready data"
}

resource "snowflake_warehouse" "platform" {
  name = local.warehouse_name

  warehouse_size = "XSMALL"

  auto_suspend = 60
  auto_resume  = "true"

  initially_suspended = true

  comment = "Compute warehouse for the Terraform Azure Data Platform project"
}

resource "snowflake_account_role" "engineer" {
  name = local.engineer_role_name

  comment = "Engineering role for the data platform"
}


resource "snowflake_account_role" "reader" {
  name = local.reader_role_name

  comment = "Read-only analytics role for curated data"
}

resource "snowflake_grant_privileges_to_account_role" "engineer_warehouse" {
  privileges = [
    "USAGE"
  ]

  account_role_name = snowflake_account_role.engineer.name

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.platform.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "reader_warehouse" {
  privileges = [
    "USAGE"
  ]

  account_role_name = snowflake_account_role.reader.name

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.platform.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "engineer_database" {
  privileges = [
    "USAGE"
  ]

  account_role_name = snowflake_account_role.engineer.name

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.platform.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "reader_database" {
  privileges = [
    "USAGE"
  ]

  account_role_name = snowflake_account_role.reader.name

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.platform.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "engineer_raw_schema" {
  privileges = [
    "USAGE",
    "CREATE TABLE",
    "CREATE VIEW",
    "CREATE STAGE",
    "CREATE FILE FORMAT"
  ]

  account_role_name = snowflake_account_role.engineer.name

  on_schema {
    schema_name = snowflake_schema.raw.fully_qualified_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "engineer_curated_schema" {
  privileges = [
    "USAGE",
    "CREATE TABLE",
    "CREATE VIEW"
  ]

  account_role_name = snowflake_account_role.engineer.name

  on_schema {
    schema_name = snowflake_schema.curated.fully_qualified_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "reader_curated_schema" {
  privileges = [
    "USAGE"
  ]

  account_role_name = snowflake_account_role.reader.name

  on_schema {
    schema_name = snowflake_schema.curated.fully_qualified_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "reader_future_tables" {
  privileges = [
    "SELECT"
  ]

  account_role_name = snowflake_account_role.reader.name

  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = snowflake_schema.curated.fully_qualified_name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "reader_future_views" {
  privileges = [
    "SELECT"
  ]

  account_role_name = snowflake_account_role.reader.name

  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_schema          = snowflake_schema.curated.fully_qualified_name
    }
  }
}

resource "snowflake_grant_account_role" "engineer_to_sysadmin" {
  role_name        = snowflake_account_role.engineer.name
  parent_role_name = "SYSADMIN"
}


resource "snowflake_grant_account_role" "reader_to_sysadmin" {
  role_name        = snowflake_account_role.reader.name
  parent_role_name = "SYSADMIN"
}