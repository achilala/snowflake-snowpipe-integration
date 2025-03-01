variable "aws" {
  description = "The AWS configuration variables"
  type = object({
    region     = string
    role_arn   = string
    access_key = string
    secret_key = string
  })
  sensitive = true
}

variable "snowflake" {
  description = "The Snowflake configuration"
  type = object({
    organization_name = string
    account_name      = string
    user              = string
    authenticator     = string
    private_key_path  = string
    warehouse         = string
    role              = string
  })
  sensitive = true
}

variable "snowflake_service_account" {
  description = "The configuration for the Snowflake service account"
  type = object({
    username           = string # Name of the Snowflake user, if any.
    password           = string # Password for the Snowflake user, if any.
    rsa_pub_key_path   = string # Path to the RSA public key for the Snowflake user, if any.
    rsa_pub_key_2_path = string # Path to the second RSA public key for the Snowflake user, if any.
  })
  sensitive = true
}
