locals {
  fqdn     = "${var.stage}.${var.dns_domain}"
  /* also used in deployment user policy */
  app_name = "${replace(var.dns_domain, ".", "-")}-app"
}

data "aws_availability_zones" "available" {
}

module "vpc" {
  source = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=0.7.0"

  namespace  = ""
  stage      = "dev"
  name       = "test"
  cidr_block = "10.0.0.0/16"
}

module "subnets" {
  source = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=0.16.0"

  availability_zones      = slice(data.aws_availability_zones.available.names, 0, var.max_availability_zones)
  namespace               = ""
  stage                   = var.stage
  name                    = local.fqdn
  vpc_id                  = module.vpc.vpc_id
  igw_id                  = module.vpc.igw_id
  cidr_block              = module.vpc.vpc_cidr_block
  nat_gateway_enabled     = "true"
  map_public_ip_on_launch = "true"
}

module "eb_application" {
  source = "git::https://github.com/lodotek/terraform-aws-elastic-beanstalk-application.git?ref=ref-0.12"

  name        = local.app_name
  description = "${local.fqdn} application"
  stage       = var.stage
  namespace   = ""
}

module "eb_environment" {
  source = "git::https://github.com/lodotek/terraform-aws-elastic-beanstalk-environment.git?ref=master"

  description         = "Dapp Discovery Store - ${local.fqdn}"
  name                = local.app_name
  stage               = var.stage
  namespace           = ""
  solution_stack_name = var.stack_name
  keypair             = var.keypair_name

  loadbalancer_certificate_arn = aws_acm_certificate.main.arn

  app             = module.eb_application.app_name
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.subnets.public_subnet_ids
  private_subnets = module.subnets.public_subnet_ids /* should be private */
  security_groups = [module.vpc.vpc_default_security_group_id]

  /* Access */
  ssh_listener_port           = "22"
  ssh_listener_enabled        = "true"
  ssh_source_restriction      = "0.0.0.0/0"
  associate_public_ip_address = "true"

  /* Application */
  application_port      = 8080
  http_listener_enabled = "true"
  env_vars              = var.env_vars

  /* Deployment */
  updating_min_in_service = 1 /* min number of hosts up during updates */
  updating_max_batch      = 1 /* max number of hosts to deploy at a time */
  rolling_update_type     = "Rolling" /* if "Immutable" replaces instances */

  /* Scaling */
  instance_type          = var.instance_type
  autoscale_min          = var.autoscale_min /* min instances */
  autoscale_max          = var.autoscale_max /* max instances */
  autoscale_measure_name = "CPUUtilization"
  autoscale_statistic    = "Average"
  autoscale_unit         = "Percent"
  autoscale_lower_bound  = 20 /* min cpu usage to remove instance */
  autoscale_upper_bound  = 80 /* max cpu usage to add an instance */
}

/* DNS ------------------------------------------*/

/* need to get the full DNS entries for the ELBs */
data "aws_elb" "main" {
  name = module.eb_environment.elb_load_balancers[0]
}

resource "gandi_zonerecord" "main" {
  zone   = var.gandi_zone_id
  name   = var.stage
  type   = "CNAME"
  ttl    = 3600
  values = ["${data.aws_elb.main.dns_name}."]
}
