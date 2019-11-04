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
  stage      = var.stage
  name       = "${local.app_name}-vpc"
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
  nat_gateway_enabled     = "false" # This costs a LOT
  map_public_ip_on_launch = "true"
}

module "eb_application" {
  source = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-application.git?ref=0.3.0"

  name        = local.app_name
  description = "${local.fqdn} application"
  stage       = var.stage
  namespace   = ""
}

module "eb_environment" {
  source = "git::https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment.git?ref=0.14.0"

  description         = "Dapp Discovery Store - ${local.fqdn}"
  name                = local.app_name
  stage               = var.stage
  region              = "us-east-1"
  solution_stack_name = var.stack_name
  keypair             = var.keypair_name

  loadbalancer_certificate_arn = aws_acm_certificate.main.arn

  vpc_id               = module.vpc.vpc_id
  application_subnets  = module.subnets.public_subnet_ids
  loadbalancer_subnets = module.subnets.public_subnet_ids /* should be private */
  allowed_security_groups = [module.vpc.vpc_default_security_group_id]
  elastic_beanstalk_application_name = module.eb_application.elastic_beanstalk_application_name

  /* Access */
  ssh_listener_port           = "22"
  ssh_listener_enabled        = "true"
  ssh_source_restriction      = "0.0.0.0/0"
  associate_public_ip_address = "true"

  /* Application */
  application_port      = 8080
  http_listener_enabled = "true"

  /* Environment */
  additional_settings = [
    for key, value in var.env_vars:
      {
        name      = key
        value     = value
        namespace = "aws:elasticbeanstalk:application:environment"
      }
  ]

  /* Deployment */
  updating_min_in_service = 1 /* min number of hosts up during updates */
  updating_max_batch      = 1 /* max number of hosts to deploy at once */
  rolling_update_type     = "Health" /* "Immutable" replaces instances */

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
  name  = module.eb_environment.load_balancers[count.index]
  count = 1
}

resource "gandi_zonerecord" "main" {
  zone   = var.gandi_zone_id
  name   = var.stage
  type   = "CNAME"
  ttl    = 3600
  values = [for elb in data.aws_elb.main: "${elb.dns_name}."]
}
