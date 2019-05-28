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

variable hosts_domain {
  description = "Domain for hosts entries."
  default     = "hosts.dap.ps"
}

variable public_domain {
  description = "Public DNS Domain address"
  default     = "dap.ps"
}

/* ENVIRONMENT ----------------------------------*/

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
