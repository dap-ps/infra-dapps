
terraform {
  required_version = ">= 0.14.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 3.34.0"
    }
    ansible = {
      source  = "nbering/ansible"
      version = " = 1.0.4"
    }
    pass = {
      source  = "camptocamp/pass"
      version = " = 1.4.0"
    }
    archive = {
      source = "hashicorp/archive"
    }
  }
}
