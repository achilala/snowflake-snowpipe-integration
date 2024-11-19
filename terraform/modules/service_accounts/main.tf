# Create the role
resource "snowflake_account_role" "this" {
  name    = var.snowflake_service_account.name
  comment = "This is the default role for the ${var.snowflake_service_account.name} user."
}

# Create the warehouse
resource "snowflake_warehouse" "this" {
  name           = var.snowflake_service_account.name
  warehouse_size = "XSMALL"
  comment        = "This is the default warehouse for the ${var.snowflake_service_account.name} user."
}

# Grant warehouse permissions to the role
resource "snowflake_grant_privileges_to_account_role" "wh" {
  privileges        = ["USAGE", "OPERATE"]
  account_role_name = snowflake_account_role.this.name
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.this.name
  }
}

# Create the user
resource "snowflake_user" "this" {
  name              = var.snowflake_service_account.name
  password          = var.snowflake_service_account.password
  rsa_public_key    = file(var.snowflake_service_account.rsa_pub_key_path)
  rsa_public_key_2  = file(var.snowflake_service_account.rsa_pub_key_2_path)
  default_role      = snowflake_account_role.this.name
  default_warehouse = snowflake_warehouse.this.name
  comment           = "This is the Snowflake account for the ${var.snowflake_service_account.name} user."
}

# create the databases
resource "snowflake_database" "this" {
  name    = "RAW"
  comment = "This is the landing database for raw data."
}

# Grant database permissions to the role
resource "snowflake_grant_privileges_to_account_role" "db" {
  all_privileges    = true
  account_role_name = snowflake_account_role.this.name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.this.name
  }
}

# Grant the role to the user
resource "snowflake_grant_account_role" "this" {
  role_name = snowflake_account_role.this.name
  user_name = snowflake_user.this.name
}
