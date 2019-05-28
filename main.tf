/* DERIVED --------------------------------------*/

provider "aws" {
  region     = "us-east-1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

provider "gandi" {
  key = "${var.gandi_api_token}"
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

resource "aws_key_pair" "admin" {
  key_name   = "admin-key"
  public_key = "${file("admin.pub")}"
}

//data "aws_ami" "ubuntu" {
//  most_recent = true
//
//  filter {
//    name   = "name"
//    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20190212.1"]
//  }
//
//  owners = [99720109477]
//}
//
//resource "aws_instance" "dev-dapps" {
//  ami               = "${data.aws_ami.ubuntu.id}"
//  instance_type     = "t3.medium"
//  availability_zone = "${var.region}"
//  key_name          = "${aws_key_pair.admin.key_name}"
//
//  tags = {
//    Name = "node-01.${var.region}.${var.env}.test"
//  }
//}

//resource "gandi_zonerecord" "main" {
//  zone   = "dap.ps"
//  name   = "dev"
//  type   = "A"
//  ttl    = 3600
//  values = ["1.2.3.4"]
//}
