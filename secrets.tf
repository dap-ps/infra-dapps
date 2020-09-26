# Uses PASSWORD_STORE_DIR environment variable
provider "pass" { refresh_store = false }

/* Access key for the AWS API. */
data "pass_password" "aws_access_key" {
  path = "cloud/AWS/access-key"
}

/* Secret key for the AWS API. */
data "pass_password" "aws_secret_key" {
  path = "cloud/AWS/secret-key"
}

/* Name of admin user for Dapp Store application. */
data "pass_password" "dap_ps_admin_user" {
  path = "service/dev/app/admin-user"
}

/* Password for admin user for Dapp Store application. */
data "pass_password" "dap_ps_admin_pass" {
  path = "service/dev/app/admin-pass"
}

/* User for accessing AWS SES SMTP endpoint. */
data "pass_password" "dap_ps_smtp_user" {
  path = "cloud/AWS/ses/smtp-access-key"
}

/* Password for accessing AWS SES SMTP endpoint. */
data "pass_password" "dap_ps_smtp_pass" {
  path = "cloud/AWS/ses/smtp-password"
}

/* An URI for DEV MongoDB database including auth information.
 * https://docs.mongodb.com/manual/reference/connection-string/ */
data "pass_password" "dap_ps_dev_db_uri" {
  path = "service/dev/mongodb/uri"
}

/* An URI for PROD MongoDB database including auth information.
 * https://docs.mongodb.com/manual/reference/connection-string/ */
data "pass_password" "dap_ps_prod_db_uri" {
  path = "service/prod/mongodb/uri"
}
