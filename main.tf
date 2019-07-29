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

variable "dev_env" {
  type = "map"

  default = {
    PORT = 4000
    ENVIRONMENT = "DEV"
    RATE_LIMIT_TIME = 15
    /* Access */
    ADMIN_USER = "${var.dap_ps_admin_use}"
    ADMIN_PASSWORD = "${var.dap_ps_admin_use}"
    /* BlockChain */
    BLOCKCHAIN_CONNECTION_POINT = "wss://ropsten.infura.io/ws/v3/8675214b97b44e96b70d05326c61fd6a"
    DISCOVER_CONTRACT = "0x17e7a7330d23fc6a2ab8578a627408f815396662"
    MAX_REQUESTS_FOR_RATE_LIMIT_TIME = 1
    /* IPFS */
    IPFS_HOST = "ipfs.infura.io"
    IPFS_PORT = 5001
    IPFS_PROTOCOL = "https"
    /* Email */
    EMAIL_USER = "${dap_ps_smtp_user}"
    EMAIL_PASSWORD = "${dap_ps_smtp_pass}"
    EMAIL_HOST = "email-smtp.us-east-1.amazonaws.com"
    EMAIL_PORT = 465
    EMAIL_TLS = "true"
    APPROVER_MAIL = "dapps-approvals@status.im"
    APPROVE_NOTIFIER_MAIL = "dapps-approvals@status.im"
    /* CloudWatch TODO */
    CLOUDWATCH_ACCESS_KEY_ID = "This is for production, if you have logging set up (AWS Cloudwatch)"
    CLOUDWATCH_REGION = "This is for production, if you have logging set up (AWS Cloudwatch)"
    CLOUDWATCH_SECRET_ACCESS_KEY = "This is for production, if you have logging set up (AWS Cloudwatch)"
  }
}

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
  /* Environment */
  env_vars      = "${var.dev_env}"
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
