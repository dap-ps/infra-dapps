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

resource "gandi_zone" "dap_ps_zone" {
  name = "${var.public_domain} zone"
}

resource "gandi_zonerecord" "domain-verification" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "_amazonses"
  type   = "TXT"
  ttl    = 3600
  values = ["\"CmTCsJqXg8DadmhGCNOWsSCXPQ8FjHkbw0SwjqLBzLM=\""]
}

resource "gandi_zonerecord" "dap_ps_dkim_1" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "zhncay5diy2lqdbq2ybrtqy7zaz5j5rb._domainkey"
  type   = "CNAME"
  ttl    = 3600
  values = ["zhncay5diy2lqdbq2ybrtqy7zaz5j5rb.dkim.amazonses.com"]
}

resource "gandi_zonerecord" "dap_ps_dkim_2" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "lkisrrqkfjmm64kksgqcwbiw6erk32do._domainkey"
  type   = "CNAME"
  ttl    = 3600
  values = ["lkisrrqkfjmm64kksgqcwbiw6erk32do.dkim.amazonses.com"]
}

resource "gandi_zonerecord" "dap_ps_dkim_3" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "bd6y7xtfpnfpuugoqmjjp7yf75ddyrv2._domainkey"
  type   = "CNAME"
  ttl    = 3600
  values = ["bd6y7xtfpnfpuugoqmjjp7yf75ddyrv2.dkim.amazonses.com"]
}

resource "gandi_zonerecord" "dap_ps_mx" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "@"
  type   = "MX"
  ttl    = 3600
  values = ["10 inbound-smtp.eu-west-1.amazonaws.com"]
}

resource "gandi_zonerecord" "dap_ps_mail_mx" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "mail"
  type   = "MX"
  ttl    = 3600
  values = ["10 feedback-smtp.eu-west-1.amazonses.com"]
}

resource "gandi_zonerecord" "dap_ps_mail_spf" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "mail"
  type   = "TXT"
  ttl    = 3600
  values = ["\"v= spf1 include:amazonses.com ~all\""]
}

resource "gandi_domainattachment" "dap_ps" {
  domain = "${var.public_domain}"
  zone   = "${gandi_zone.dap_ps_zone.id}"
}

/* MAIL SITE ------------------------------------*/

/* This is the main site hosted on GitHub */
resource "gandi_zonerecord" "dap_ps_site" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "mail"
  type   = "TXT"
  ttl    = 3600
  values = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ]
}

/* RESOURCES ------------------------------------*/

resource "aws_key_pair" "admin" {
  key_name   = "admin-key"
  public_key = "${file("admin.pub")}"
}

data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["${var.image_name}"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "dap_ps_dev" {
  ami               = "${data.aws_ami.ubuntu.id}"
  instance_type     = "${var.instance_type}"
  availability_zone = "${var.zone}"
  key_name          = "${aws_key_pair.admin.key_name}"

  tags = {
    Name = "node-01.${var.zone}.${var.env}.test"
  }
}

resource "gandi_zonerecord" "main" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "dev"
  type   = "A"
  ttl    = 3600
  values = ["${aws_instance.dap_ps_dev.public_ip}"]
}
