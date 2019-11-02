/* REQUIRED -------------------------------------*/

variable "aws_access_key" {
  description = "Access key for the AWS API."
}

variable "aws_secret_key" {
  description = "Secret key for the AWS API."
}

variable "gandi_api_token" {
  description = "API token for Gandi DNS API"
}

/* GENERAL --------------------------------------*/

variable "hosts_subdomain" {
  description = "Domain for hosts entries."
  default     = "hosts"
}

variable "public_domain" {
  description = "Public DNS Domain address"
  default     = "dap.ps"
}

/* ENVIRONMENT ----------------------------------*/

variable "group" {
  description = "Name of Ansible group"
  default     = "dap-ps-dev"
}

variable "env" {
  description = "Name of environment to create"
  default     = "dapps"
}

variable "image_name" {
  description = "Name of AMI image to use."
  default     = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20190212.1"
}

variable "ssh_user" {
  description = "Default user to use when accesing host via SSH."
  default     = "ubuntu"
}

variable "stack_name" {
  description = "Elastic Beanstalk stack, e.g. Docker, Go, Node, Java, IIS."
  default     = "64bit Amazon Linux 2018.03 v4.11.0 running Node.js"
  /* http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts.platforms.html */
}

/* DEV Dap.ps -----------------------------------*/

variable "dap_ps_app_bucket_name" {
  description = "Name of bucket to which we deploy the dap.ps dapp"
  default     = "dev-dap-ps-app"
}

variable "dap_ps_admin_user" {
  description = "Name of admin user for Dapp Store application."
}

variable "dap_ps_admin_pass" {
  description = "Password for admin user for Dapp Store application."
}

variable "dap_ps_smtp_user" {
  description = "User for accessing AWS SES SMTP endpoint."
}

variable "dap_ps_smtp_pass" {
  description = "Password for accessing AWS SES SMTP endpoint."
}

variable "dap_ps_dev_db_uri" {
  description = "An URI for DEV MongoDB database including auth information."
  /* https://docs.mongodb.com/manual/reference/connection-string/ */
}

variable "dap_ps_prod_db_uri" {
  description = "An URI for PROD MongoDB database including auth information."
  /* https://docs.mongodb.com/manual/reference/connection-string/ */
}

/* SES FORWARDER --------------------------------*/

variable "ses_forwarder_bucket_name" {
  description = "Name of bucket to use for storing forwarded emails"
  default     = "ses-forwarder-emails"
}

variable "ses_forwarder_admin_account_arn" {
  description = "Name of bucket to use for storing forwarded emails"
  default     = "arn:aws:iam::760668534108:user/jakubgs"
}

