# configure the AWS provider
provider "aws" {
  region     = var.aws.region
  access_key = var.aws.access_key
  secret_key = var.aws.secret_key
}

# configure the Snowflake provider
provider "snowflake" {
  account       = var.snowflake.account
  user          = var.snowflake.user
  authenticator = var.snowflake.authenticator
  private_key   = file(var.snowflake.private_key_path)
  warehouse     = var.snowflake.warehouse
  role          = var.snowflake.role
}
