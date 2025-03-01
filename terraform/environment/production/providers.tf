# configure the AWS provider
provider "aws" {
  region     = var.aws.region
  access_key = var.aws.access_key
  secret_key = var.aws.secret_key
}

# configure the Snowflake provider
provider "snowflake" {
  organization_name = var.snowflake.organization_name
  account_name      = var.snowflake.account_name
  user              = var.snowflake.user
  authenticator     = var.snowflake.authenticator
  private_key       = file(var.snowflake.private_key_path)
  warehouse         = var.snowflake.warehouse
  role              = var.snowflake.role
  preview_features_enabled = [
    "snowflake_external_volume_resource",
    "snowflake_pipe_resource",
    "snowflake_stage_resource",
    "snowflake_stages_datasource",
    "snowflake_storage_integration_resource",
    "snowflake_table_resource"
  ]
}
