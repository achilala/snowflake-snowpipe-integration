# required providers and their versions 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.64.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "1.0.3"
    }
  }
}
