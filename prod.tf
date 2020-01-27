locals {
  prod_env = {
    /* Node start command */
    EB_NODE_COMMAND = "node server.js"
    /* WARNING EB forces PORT 8081 */
    ENVIRONMENT        = "PROD"
    RATE_LIMIT_TIME    = 15 /* ms window */
    RATE_LIMIT_MAX_REQ = 1
    /* Access */
    ADMIN_USER     = var.dap_ps_admin_user
    ADMIN_PASSWORD = var.dap_ps_admin_pass
    /* Database */
    DB_CONNECTION = var.dap_ps_prod_db_uri
    /* Blockchain */
    BLOCKCHAIN_CONNECTION_POINT      = "wss://mainnet.infura.io/v3/8675214b97b44e96b70d05326c61fd6a"
    DISCOVER_CONTRACT                = "0x5bCF2767F86f14eDd82053bfBfd5069F68C2C5F8"
    /* IPFS */
    IPFS_HOST     = "ipfs.status.im"
    IPFS_PORT     = 443
    IPFS_PROTOCOL = "https"
    /* Email */
    EMAIL_USER            = var.dap_ps_smtp_user
    EMAIL_PASSWORD        = var.dap_ps_smtp_pass
    EMAIL_HOST            = "email-smtp.us-east-1.amazonaws.com"
    EMAIL_PORT            = 465
    EMAIL_TLS             = "true"
    APPROVE_NOTIFIER_MAIL = "approvals@dap.ps" /* FROM */
    APPROVER_MAIL         = "dapps-approvals@status.im"
    /* CloudWatch TODO Once we have logging set up (AWS Cloudwatch) */
    CLOUDWATCH_ACCESS_KEY_ID     = "TODO"
    CLOUDWATCH_REGION            = "TODO"
    CLOUDWATCH_SECRET_ACCESS_KEY = "TODO"
  }
}

module "prod_cert" {
  source  = "./modules/aws-acm-cert"
  stage   = "prod"
  domain  = "dap.ps"
  sans    = ["dap.ps", "raw.prod.dap.ps"]
  zone_id = aws_route53_zone.dap_ps.zone_id

  route53_zone_id = aws_route53_zone.dap_ps.zone_id
}

module "prod_db_bucket" {
  source      = "./modules/aws-s3-bucket"
  bucket_name = "prod-dap-ps-db-backups"
  description = "Bucket for MongoDB backups on db.prod"
}

module "prod_db" {
  source     = "./modules/aws-ec2-instance"
  groups     = ["mongodb"]
  env        = "db"
  stage      = "prod"
  host_count = 3
  subdomain  = var.hosts_subdomain
  domain     = var.public_domain
  open_ports = [27017] /* mongodb */

  /* Network */
  vpc_id     = module.prod_env.vpc_id
  subnet_id  = module.prod_env.subnet_ids[0]
  sec_group  = module.prod_env.security_group_id

  /* Plumbing */
  keypair_name    = aws_key_pair.admin.key_name
  route53_zone_id = aws_route53_zone.dap_ps.zone_id
}

module "prod_env" {
  source     = "./modules/aws-eb-env"
  name       = "prod-dap-ps"
  stage      = "prod"
  env_vars   = local.prod_env
  dns_domain = var.public_domain
  stack_name = var.stack_name

  /* Plumbing */
  cert_arn      = module.prod_cert.arn
  keypair_name  = aws_key_pair.admin.key_name

  /* Scaling */
  instance_type = "t2.micro"
  autoscale_min = 2
  autoscale_max = 6
}

module "prod_cdn" {
  source       = "./modules/aws-cloud-front"
  env          = "dap-ps"
  stage        = "prod"
  aliases      = ["dap.ps", "prod.dap.ps"]
  cert_arn     = module.prod_cert.arn
  origin_fqdns = module.prod_env.elb_fqdns
}

/* AWS DNS --------------------------------------*/

/* raw subdomain for access without CDN */
resource "aws_route53_record" "prod_dns_raw" {
  zone_id = aws_route53_zone.dap_ps.zone_id
  name    = "raw.prod"
  type    = "CNAME"
  ttl     = 3600
  records = [for elb in module.prod_env.elb_fqdns: "${elb}."]
}

resource "aws_route53_record" "prod_dns_cdn" {
  zone_id = aws_route53_zone.dap_ps.zone_id
  name    = "cdn.prod"
  type    = "CNAME"
  ttl     = 3600
  records = ["${module.prod_cdn.cf_domain_name}."]
}

resource "aws_route53_record" "prod_dns" {
  zone_id = aws_route53_zone.dap_ps.zone_id
  name    = "prod"
  type    = "CNAME"

  alias {
    name    = aws_route53_record.prod_dns_cdn.fqdn
    zone_id = aws_route53_record.prod_dns_cdn.zone_id

    evaluate_target_health = false
  }
}

/* Apex DNS Record ------------------------------*/

/* WARNING: Main site record for https://dap.ps/ */
resource "aws_route53_record" "prod_dns_apex" {
  zone_id = aws_route53_zone.dap_ps.zone_id
  name    = ""
  type    = "A"

  alias {
    name    = module.prod_cdn.cf_domain_name
    zone_id = module.prod_cdn.cf_zone_id

    evaluate_target_health = false
  }
}
