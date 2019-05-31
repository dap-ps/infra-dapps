/* REQUIRED -------------------------------------*/

variable aws_access_key {
  description = "Access key for the AWS API."
}

variable aws_secret_key {
  description = "Secret key for the AWS API."
}

variable gandi_api_token {
  description = "API token for Gandi DNS API"
}

/* GENERAL --------------------------------------*/

variable hosts_subdomain {
  description = "Domain for hosts entries."
  default     = "hosts"
}

variable public_domain {
  description = "Public DNS Domain address"
  default     = "dap.ps"
}

/* ENVIRONMENT ----------------------------------*/

variable group {
  description = "Name of Ansible group"
  default     = "dap-ps-dev"
}

variable env {
  description = "Name of environment to create"
  default     = "dapps"
}

variable zone {
  description = "Name of availability zone to deploy to."
  default     = "us-east-1a"
}

variable image_name {
  description = "Name of AMI image to use."
  default     = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20190212.1"
}

variable instance_type {
  description = "Name of instance type to use"
  default     = "t3.medium"
}

variable ssh_user {
  description = "Default user to use when accesing host via SSH."
  default     = "ubuntu"
}

/* SES FORWARDER --------------------------------*/

variable ses_forwarder_bucket_name {
  description = "Name of bucket to use for storing forwarded emails"
  default     = "ses-forwarder-emails"
}

variable ses_forwarder_admin_account_arn {
  description = "Name of bucket to use for storing forwarded emails"
  default     = "arn:aws:iam::760668534108:user/jakubgs"
}
