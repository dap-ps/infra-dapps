locals {
  fqdn = "${var.stage}.${var.dns_domain}"
}

/* SSL Certificate ------------------------------*/

resource "aws_acm_certificate" "main" {
  domain_name               = "${var.stage}.${var.dns_domain}"
  /* TODO support SAN of dap.ps */
  subject_alternative_names = []
  validation_method         = "DNS"
}

resource "gandi_zonerecord" "prod_cert_verification" {
  zone   = "${var.gandi_zone_id}"
  name   = "${replace(aws_acm_certificate.main.domain_validation_options.0.resource_record_name, ".${var.dns_domain}.", "")}"
  type   = "${aws_acm_certificate.main.domain_validation_options.0.resource_record_type}"
  ttl    = 300
  values = ["${aws_acm_certificate.main.domain_validation_options.0.resource_record_value}"]
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = "${aws_acm_certificate.main.arn}"
  validation_record_fqdns = ["${gandi_zonerecord.prod_cert_verification.name}.${var.dns_domain}"]
}

/* Resources ------------------------------------*/

data "aws_availability_zones" "available" {}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=0.4.1"
  namespace  = ""
  stage      = "dev"
  name       = "test"
  cidr_block = "10.0.0.0/16"
}

module "subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=0.12.0"
  availability_zones  = ["${slice(data.aws_availability_zones.available.names, 0, var.max_availability_zones)}"]
  namespace           = ""
  stage               = "${var.stage}"
  name                = "${local.fqdn}"
  vpc_id              = "${module.vpc.vpc_id}"
  igw_id              = "${module.vpc.igw_id}"
  cidr_block          = "${module.vpc.vpc_cidr_block}"
  nat_gateway_enabled = "true"
}

module "eb_application" {
  source      = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-application.git?ref=0.1.6"
  name        = "${replace(var.dns_domain, ".", "-")}-eb-app"
  description = "${local.fqdn} application"
  stage       = "${var.stage}"
  namespace   = ""
}

module "eb_environment" {
  source                       = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment.git?ref=0.13.0"
  description                  = "Dapp Discovery Store - ${local.fqdn}"
  name                         = "${replace(var.dns_domain, ".", "-")}-eb-app"
  stage                        = "${var.stage}"
  namespace                    = ""
  solution_stack_name          = "${var.stack_name}"
  keypair                      = "${var.keypair_name}"
  loadbalancer_certificate_arn = "${aws_acm_certificate.main.arn}"
  app                          = "${module.eb_application.app_name}"
  vpc_id                       = "${module.vpc.vpc_id}"
  public_subnets               = "${module.subnets.public_subnet_ids}"
  private_subnets              = "${module.subnets.private_subnet_ids}"
  security_groups              = ["${module.vpc.vpc_default_security_group_id}"]
}

/* DNS ------------------------------------------*/

resource "gandi_zonerecord" "main" {
  zone   = "${var.gandi_zone_id}"
  name   = "${var.stage}"
  type   = "CNAME"
  ttl    = 3600
  values = ["${module.eb_environment.elb_load_balancers}"]
}