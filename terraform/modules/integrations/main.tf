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

# create the schemas
resource "snowflake_schema" "this" {
  name         = local.data_source_upper
  database     = snowflake_database.this.name
  is_transient = true
  comment      = "Stores raw data for the ${local.data_source} data source."
}

# create the tables
resource "snowflake_table" "this" {
  database        = snowflake_schema.this.database
  schema          = snowflake_schema.this.name
  name            = "USERS"
  comment         = "Table for the users data"
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
      constant = var.snowflake_service_account.name
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

# import module from registry
module "my_snowpipe" {
  source  = "Snowflake-Labs/snowpipe-aws/snowflake"
  version = "0.3.1"

  database_name = snowflake_database.this.name
  schema_name   = snowflake_schema.this.name
  stage_name    = snowflake_table.this.name
  pipe_name     = snowflake_table.this.name

  aws_s3_url               = lower("${module.storage-integration-aws.bucket_url}${local.data_source}/${snowflake_table.this.name}/")
  aws_sns_topic_arn        = module.storage-integration-aws.sns_topic_arn
  storage_integration_name = module.storage-integration-aws.storage_integration_name

  destination_table_name = snowflake_table.this.name
  custom_ingest_columns = {
    target_columns = [
      "DOCUMENT",
    ]
    source_columns = [
      "$1",
    ]
  }

  comment = "Ingest Pipe."
  providers = {
    snowflake.ingest_role = snowflake
  }
}
