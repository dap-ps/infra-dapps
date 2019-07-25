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

/* ENVIRONMENTS ---------------------------------*/

module "dev" {
  source        = "./modules/dev"
  name          = "dev-dap-ps"
  gandi_zone_id = "${gandi_zone.dap_ps_zone.id}"
  dns_domain    = "dap.ps"
  dns_entry     = "dev"
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
