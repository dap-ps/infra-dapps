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

/* ENVIRONMENTS ---------------------------------*/

module "dev" {
  source        = "./modules/dev"
  name          = "dev-dap-ps"
  gandi_zone_id = "${gandi_zone.dap_ps_zone.id}"
  dns_domain    = "dap.ps"
  dns_entry     = "dev"
}
