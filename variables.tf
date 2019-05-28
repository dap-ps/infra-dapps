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

variable region {
  description = "Name of region to deploy to"
  default     = "us-east-1"
}
