# snowflake-snowpipe-integration

This is a Terraform project implementing Snowflake's (Automating Snowpipe for Amazon S3)[https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto-s3] integration.

It does so by reusing Snowflake's terraform modules (storage-integration-aws)[https://registry.terraform.io/modules/Snowflake-Labs/storage-integration-aws/snowflake/latest] and (snowpipe-aws)[https://registry.terraform.io/modules/Snowflake-Labs/snowpipe-aws/snowflake/latest].


## Configuration

### Terraform variables configuration
Sample `terraform.tfvars` file
```tf
aws = {
  region     = ""
  access_key = ""
  secret_key = ""
}

snowflake = {
  account          = ""
  user             = ""
  authenticator    = "JWT"
  private_key_path = ""
  warehouse        = ""
  role             = ""
}

snowflake_service_account = {
  name               = ""
  password           = ""
  rsa_pub_key_path   = ""
  rsa_pub_key_2_path = ""
}
```
:closed_lock_with_key: Learn more about Snowflake's key-pair authentication here: (Key-pair authentication and key-pair rotation)[https://docs.snowflake.com/en/user-guide/key-pair-auth]

### Setting up infrastructure
```sh
cd terraform
terraform init
terraform apply
```

:warning: Running `terraform apply` might fail the first time, due to the stage unable to assume the AWS role. A lag in creating it might be the issue. Re-running `terraform apply` fixes this.

:bug: There's a deprecated resource in one of the modules that might raise an error. I found that commenting it out from this file does the trick `snowflake-snowpipe-integration/terraform/.terraform/modules/storage-integration-aws/storage_integration.tf`
```tf
# resource "snowflake_integration_grant" "this" {
#   provider         = snowflake.storage_integration_role
#   integration_name = snowflake_storage_integration.this.name

#   privilege = "USAGE"
#   roles     = var.snowflake_integration_user_roles

#   with_grant_option = false
# }
```


### Airbyte

### Airbyte variables configuration
Sample `.env` file
```env
# Gitlab config
GITLAB_API_TOKEN=""
GITLAB_PROJECTS=""
GITLAB_START_DATE=""

# AWS config
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
S3_BUCKET_NAME=""
S3_BUCKET_PATH=""
S3_BUCKET_REGION=""
```

## Landing data 
```sh
cd ../snowflake-snowpipe-integration
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

```sh
cd airbyte
python man.py
```
