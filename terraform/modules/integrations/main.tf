# create the schemas
resource "snowflake_schema" "this" {
  name         = var.schema_name
  database     = var.database_name
  is_transient = true
  comment      = "Stores raw data for the ${var.datasource_name} data source."
}

# create the tables
resource "snowflake_table" "this" {
  database        = var.database_name
  schema          = var.schema_name
  name            = var.table_name
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
      constant = var.snowflake_service_account_name
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

  database_name = var.database_name
  schema_name   = var.schema_name
  stage_name    = var.table_name
  pipe_name     = var.table_name

  aws_s3_url               = lower("${module.storage-integration-aws.bucket_url}${var.integration.datasource}/${var.table_name}/")
  aws_sns_topic_arn        = module.storage-integration-aws.sns_topic_arn
  storage_integration_name = module.storage-integration-aws.storage_integration_name

  destination_table_name = var.table_name
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
