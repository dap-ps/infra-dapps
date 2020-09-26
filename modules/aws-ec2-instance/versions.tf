terraform {
  required_version = "~> 0.13.3"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "= 2.46.0"
    }
    ansible = {
      source  = "nbering/ansible"
      version = " = 1.0.4"
    }
  }
}
