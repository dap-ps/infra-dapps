locals {
  fqdn = "${var.stage}.${var.dns_domain}"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=0.4.1"

  namespace  = ""
  stage      = "dev"
  name       = "test"
  cidr_block = "10.0.0.0/16"
}

module "subnets" {
  source = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=0.12.0"

  availability_zones      = ["${slice(data.aws_availability_zones.available.names, 0, var.max_availability_zones)}"]
  namespace               = ""
  stage                   = "${var.stage}"
  name                    = "${local.fqdn}"
  vpc_id                  = "${module.vpc.vpc_id}"
  igw_id                  = "${module.vpc.igw_id}"
  cidr_block              = "${module.vpc.vpc_cidr_block}"
  nat_gateway_enabled     = "true"
  map_public_ip_on_launch = "true"
}

module "eb_application" {
  source = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-application.git?ref=0.1.6"

  name        = "${replace(var.dns_domain, ".", "-")}-app"
  description = "${local.fqdn} application"
  stage       = "${var.stage}"
  namespace   = ""
}

module "eb_environment" {
  source = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment.git?ref=0.13.0"

  description         = "Dapp Discovery Store - ${local.fqdn}"
  name                = "${replace(var.dns_domain, ".", "-")}-app"
  stage               = "${var.stage}"
  namespace           = ""
  solution_stack_name = "${var.stack_name}"
  keypair             = "${var.keypair_name}"

  app                          = "${module.eb_application.app_name}"
  loadbalancer_certificate_arn = "${aws_acm_certificate.main.arn}"
  vpc_id                       = "${module.vpc.vpc_id}"
  public_subnets               = "${module.subnets.public_subnet_ids}"
  private_subnets              = "${module.subnets.private_subnet_ids}"
  security_groups              = ["${module.vpc.vpc_default_security_group_id}"]

  /* Access */
  ssh_listener_port           = "22"
  ssh_listener_enabled        = "true"
  ssh_source_restriction      = "0.0.0.0/0"
  associate_public_ip_address = "true"

  /* Application */
  application_port      = 8080
  http_listener_enabled = "true"
  env_vars              = "${var.env_vars}"

  /* Scaling */
  instance_type          = "t2.micro"
  autoscale_min          = "${var.autoscale_min}" /* min instances */
  autoscale_max          = "${var.autoscale_max}" /* max instances */
  autoscale_measure_name = "CPUUtilization"
  autoscale_statistic    = "Average"
  autoscale_unit         = "Percent"
  autoscale_lower_bound  = 20                     /* min cpu usage to remove instance */
  autoscale_upper_bound  = 80                     /* max cpu usage to add an instance */
}

/* DNS ------------------------------------------*/

/* need to get the full DNS entries for the ELBs */
data "aws_elb" "main" {
  name  = "${module.eb_environment.elb_load_balancers[0]}"
}

resource "gandi_zonerecord" "main" {
  zone   = "${var.gandi_zone_id}"
  name   = "${var.stage}"
  type   = "CNAME"
  ttl    = 3600
  values = ["${data.aws_elb.main.dns_name}."]
}
