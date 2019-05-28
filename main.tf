/* DERIVED --------------------------------------*/

provider "aws" {
  region     = "us-east-1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

/* DATA -----------------------------------------*/

terraform {
  backend "s3" {
    bucket     = "dapps-terraform-state"
    key        = "infra-dapps"
    region     = "us-east-1"
    encrypt    = true
  }
}

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

data "aws_ami" "debian" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-stretch-hvm-arm64-gp2-2019-04-28-63458"]
  }

  owners = [379101102735]
}

//resource "aws_instance" "dev-dapps" {
//  ami           = "${data.aws_ami.ubuntu.id}"
//  instance_type = "t3.medium"
//
//  tags = {
//    Name = "${var.name}-${format("%02d", count.index+1)}.${local.dc}.${var.env}.${local.stage}"
//  }
//}
