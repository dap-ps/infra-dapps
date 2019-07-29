/* DERIVED --------------------------------------*/

provider "aws" {
  region     = "us-east-1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  version    = "<= 2.20.0"
}

provider "gandi" {
  key = "${var.gandi_api_token}"
  version    = "<= 1.0.1"
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

  policy = "${file("files/s3-policy.json")}"

  versioning {
    enabled = true
  }
 
  lifecycle {
    prevent_destroy = true
  }
}

/* Gandi DNS ------------------------------------*/

resource "gandi_zone" "dap_ps_zone" {
  name = "${var.public_domain} zone"
}

resource "gandi_domainattachment" "dap_ps" {
  domain = "${var.public_domain}"
  zone   = "${gandi_zone.dap_ps_zone.id}"
}

/* ACCESS ---------------------------------------*/

resource "aws_key_pair" "admin" {
  key_name   = "admin-key"
  public_key = "${file("files/admin.pub")}"
}

/* ENVIRONMENTS ---------------------------------*/

module "dev" {
  source        = "./modules/aws-eb-env"
  name          = "dev-dap-ps"
  gandi_zone_id = "${gandi_zone.dap_ps_zone.id}"
  dns_domain    = "dap.ps"
  stage         = "dev"
  stack_name    = "${var.stack_name}"
  keypair_name  = "${aws_key_pair.admin.key_name}"
  /* Scaling */
  autoscale_min = 1
  autoscale_max = 2
}

module "prod" {
  source        = "./modules/prod"
  name          = "prod-dap-ps"
  gandi_zone_id = "${gandi_zone.dap_ps_zone.id}"
  dns_domain    = "dap.ps"
  dns_entry     = "prod" /* just means use `dap.ps` */
}

/* MAIN SITE ------------------------------------*/

/**
 * This is the main site hosted on GitHub:
 * https://github.com/dap-ps/discover
 **/
resource "gandi_zonerecord" "dap_ps_site" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "@"
  type   = "A"
  ttl    = 3600
  values = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ]
}
