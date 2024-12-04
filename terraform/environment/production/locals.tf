locals {
  integration_name       = "snowflake-aws-integration"
  integration_name_upper = replace(upper(local.integration_name), "-", "_")
  environment            = "dev"
  data_source            = "Gitlab"
  data_source_upper      = upper("Gitlab")
}
