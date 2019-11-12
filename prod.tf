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
    IPFS_HOST     = "ipfs.infura.io"
    IPFS_PORT     = 5001
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
  sans    = ["dap.ps"]
  zone_id = gandi_zone.dap_ps_zone.id
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
  keypair_name  = aws_key_pair.admin.key_name
  gandi_zone_id = gandi_zone.dap_ps_zone.id
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

/* DNS ------------------------------------------*/

resource "gandi_zonerecord" "prod_dns" {
  zone   = gandi_zone.dap_ps_zone.id
  name   = "prod"
  type   = "CNAME"
  ttl    = 3600
  values = ["${module.prod_cdn.cf_domain_name}."]
}

/* Apex DNS records cannot be CNAMEs */
data "dns_a_record_set" "prod_cdn" {
  host  = module.prod_cdn.cf_domain_name
}

resource "gandi_zonerecord" "prod_apex_dns" {
  zone   = gandi_zone.dap_ps_zone.id
  name   = "@"
  type   = "A"
  ttl    = 3600
  values = data.dns_a_record_set.prod_cdn.addrs
}
