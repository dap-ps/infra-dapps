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

/* SES EMail Fowarding --------------------------*/

resource "gandi_zone" "dap_ps" {
  name = "${var.public_domain} zone"
}

resource "gandi_zonerecord" "domain-verification" {
  zone   = "${gandi_zone.dap_ps.id}"
  name   = "_amazonses"
  type   = "TXT"
  ttl    = 3600
  values = ["\"CmTCsJqXg8DadmhGCNOWsSCXPQ8FjHkbw0SwjqLBzLM=\""]
}

resource "gandi_zonerecord" "dkim-1" {
  zone   = "${gandi_zone.dap_ps.id}"
  name   = "zhncay5diy2lqdbq2ybrtqy7zaz5j5rb._domainkey"
  type   = "CNAME"
  ttl    = 3600
  values = ["zhncay5diy2lqdbq2ybrtqy7zaz5j5rb.dkim.amazonses.com"]
}

resource "gandi_zonerecord" "dkim-2" {
  zone   = "${gandi_zone.dap_ps.id}"
  name   = "lkisrrqkfjmm64kksgqcwbiw6erk32do._domainkey"
  type   = "CNAME"
  ttl    = 3600
  values = ["lkisrrqkfjmm64kksgqcwbiw6erk32do.dkim.amazonses.com"]
}

resource "gandi_zonerecord" "dkim-3" {
  zone   = "${gandi_zone.dap_ps.id}"
  name   = "bd6y7xtfpnfpuugoqmjjp7yf75ddyrv2._domainkey"
  type   = "CNAME"
  ttl    = 3600
  values = ["bd6y7xtfpnfpuugoqmjjp7yf75ddyrv2.dkim.amazonses.com"]
}

resource "gandi_zonerecord" "email" {
  zone   = "${gandi_zone.dap_ps.id}"
  name   = "@"
  type   = "MX"
  ttl    = 3600
  values = ["10 inbound-smtp.eu-west-1.amazonaws.com"]
}

/* RESOURCES ------------------------------------*/

resource "aws_key_pair" "admin" {
  key_name   = "admin-key"
  public_key = "${file("admin.pub")}"
}
