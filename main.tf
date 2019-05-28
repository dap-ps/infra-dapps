/* DERIVED --------------------------------------*/

provider "aws" {
  region     = "us-east-1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

//provider "gandi" {
//  key = "<the API key>"
//  sharing_id = "<the sharing_id>"
//}

/* DATA -----------------------------------------*/

//terraform {
//  backend "s3" {
//    bucket  = "dapps-terraform-state"
//    key     = "infra-dapps"
//    region  = "us-east-2"
//    encrypt = true
//  }
//}

/* INVENTORY ------------------------------------*/

resource "aws_s3_bucket" "tf-state" {
  bucket = "dapps-terraform-state"
  acl    = "private"

  tags = {
    Name = "Terraform State Store"
  }

  policy = "${file("s3policy.json")}"

  versioning {
    enabled = true
  }
 
  lifecycle {
    prevent_destroy = true
  }
}

/* RESOURCES ------------------------------------*/
