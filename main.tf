/* DERIVED --------------------------------------*/

provider "aws" {
  region     = "us-east-1"
  access_key = data.pass_password.aws_access_key.password
  secret_key = data.pass_password.aws_secret_key.password
}

/* DATA -----------------------------------------*/

terraform {
  backend "s3" {
    bucket  = "dapps-terraform-state"
    key     = "infra-dapps"
    region  = "us-east-1"
    encrypt = true
  }
}

/* INVENTORY ------------------------------------*/

resource "aws_s3_bucket" "tf-state" {
  bucket = "dapps-terraform-state"
  acl    = "private"

  tags = {
    Name = "Terraform State Store"
  }

  policy = file("files/s3-policy.json")

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

/* ACCESS ---------------------------------------*/

resource "aws_key_pair" "admin" {
  key_name   = "admin-key"
  public_key = file("files/admin.pub")
}

data "aws_caller_identity" "current" {}
