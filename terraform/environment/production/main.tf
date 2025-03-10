# import module from registry
module "storage-integration-aws" {
  source  = "Snowflake-Labs/storage-integration-aws/snowflake"
  version = "0.2.10"

  prefix = local.integration_name
  env    = local.environment

  providers = {
    snowflake.storage_integration_role = snowflake
    aws                                = aws
  }
}

# create external volume
resource "snowflake_external_volume" "this" {
  name = local.integration_name_upper
  storage_location {
    storage_location_name = local.integration_name_upper
    storage_base_url      = module.storage-integration-aws.bucket_url
    storage_provider      = "S3"
    storage_aws_role_arn  = var.aws.role_arn
  }
  comment = "This is external volume to use with iceberg tables."
}

# create the databases
resource "snowflake_database" "this" {
  for_each = var.datasources

  name            = each.value.name
  catalog         = "SNOWFLAKE"
  external_volume = snowflake_external_volume.this.name
  comment         = each.value.name
}

# create the schemas
resource "snowflake_schema" "this" {
  for_each = { for s in local.schemas : "${s.db_key}.${s.schema_key}" => s }

  database     = snowflake_database.this[each.value.db_key].name
  is_transient = true
  name         = each.value.schema.name
  comment      = each.value.schema.comment
}

# create the tables
resource "snowflake_table" "tables" {
  for_each = { for t in local.tables : "${t.db_key}.${t.schema_key}.${t.table_key}" => t }

  database        = snowflake_database.this[each.value.db_key].name
  schema          = snowflake_schema.this["${each.value.db_key}.${each.value.schema_key}"].name
  name            = each.value.table.name
  comment         = each.value.table.comment
  cluster_by      = ["to_date(_LOADED_AT)"]
  change_tracking = false

  column {
    name     = "_LOADED_AT"
    type     = "TIMESTAMP_NTZ(9)"
    nullable = false
    default {
      expression = "CURRENT_TIMESTAMP()"
    }
    comment = "Timestamp when this data was loaded"
  }

  column {
    name     = "_LOADED_BY"
    type     = "text"
    nullable = false
    default {
      constant = var.snowflake_service_account.username
    }
    comment = "ETL user"
  }

  column {
    name     = "DOCUMENT"
    type     = "VARIANT"
    nullable = false
    comment  = "JSON payload"
  }
}

# Create the role
resource "snowflake_account_role" "this" {
  name    = var.snowflake_service_account.username
  comment = "This is the default role for the ${var.snowflake_service_account.username} user."
}

# Create the warehouse
resource "snowflake_warehouse" "this" {
  name           = var.snowflake_service_account.username
  warehouse_size = "XSMALL"
  comment        = "This is the default warehouse for the ${var.snowflake_service_account.username} user."
}

# Create the user
resource "snowflake_user" "this" {
  name              = var.snowflake_service_account.username
  password          = var.snowflake_service_account.password
  rsa_public_key    = file(var.snowflake_service_account.rsa_pub_key_path)
  rsa_public_key_2  = file(var.snowflake_service_account.rsa_pub_key_2_path)
  default_role      = snowflake_account_role.this.name
  default_warehouse = snowflake_warehouse.this.name
  comment           = "This is the Snowflake account for the ${var.snowflake_service_account.username} user."
}

# Grant warehouse permissions to the role
resource "snowflake_grant_privileges_to_account_role" "wh" {
  privileges        = ["USAGE", "OPERATE"]
  account_role_name = snowflake_account_role.this.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.this.name
  }
}

# Grant database permissions to the role
resource "snowflake_grant_privileges_to_account_role" "db" {
  for_each = var.datasources

  all_privileges    = true
  account_role_name = snowflake_account_role.this.name
  on_account_object {
    object_type = "DATABASE"
    object_name = each.value.name
  }
}

# Grant the role to the user
resource "snowflake_grant_account_role" "this" {
  role_name = snowflake_account_role.this.name
  user_name = snowflake_user.this.name
}

# import module from registry
module "my_snowpipe" {
  source  = "Snowflake-Labs/snowpipe-aws/snowflake"
  version = "0.3.1"

  for_each = { for t in local.tables : "${t.db_key}.${t.schema_key}.${t.table_key}" => t }

  database_name = snowflake_database.this[each.value.db_key].name
  schema_name   = snowflake_schema.this["${each.value.db_key}.${each.value.schema_key}"].name
  stage_name    = each.value.table.name
  pipe_name     = each.value.table.name

  aws_s3_url               = lower("${module.storage-integration-aws.bucket_url}${local.data_source}/${each.value.table.name}/")
  aws_sns_topic_arn        = module.storage-integration-aws.sns_topic_arn
  storage_integration_name = module.storage-integration-aws.storage_integration_name

  destination_table_name = each.value.table.name
  custom_ingest_columns = {
    target_columns = [
      "DOCUMENT",
    ]
    source_columns = [
      "$1",
    ]
  }

  comment = "This snowpipe loads data that is available in the stage ${snowflake_database.this[each.value.db_key].name}.${snowflake_schema.this["${each.value.db_key}.${each.value.schema_key}"].name}.${each.value.table.name}."
  providers = {
    snowflake.ingest_role = snowflake
  }
}
