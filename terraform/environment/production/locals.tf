locals {
  integration_name       = "snowflake-aws-integration"
  integration_name_upper = replace(upper(local.integration_name), "-", "_")
  environment            = "dev"
  data_source            = "Gitlab"
  data_source_upper      = upper("Gitlab")
}

locals {
  schemas = flatten([
    for db_key, db_value in var.datasources : [
      for schema_key, schema_value in db_value.schemas : {
        db_key     = db_key
        schema_key = schema_key
        schema     = schema_value
      }
    ]
  ])
}

locals {
  tables = flatten([
    for db_key, db_value in var.datasources : [
      for schema_key, schema_value in db_value.schemas : [
        for table_key, table_value in schema_value.tables : {
          db_key     = db_key
          schema_key = schema_key
          table_key  = table_key
          table      = table_value
        }
      ]
    ]
  ])
}