# required providers and their versions 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.64.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.98.0"
    }
  }
}
