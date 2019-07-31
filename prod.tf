locals {
  prod_env = {
    /* WARNING EB forces PORT 8081 */
    ENVIRONMENT     = "PROD"
    RATE_LIMIT_TIME = 15
    /* Access */
    ADMIN_USER     = var.dap_ps_admin_user
    ADMIN_PASSWORD = var.dap_ps_admin_pass
    /* Database */
    DB_CONNECTION = var.dap_ps_prod_db_uri
    /* Blockchain */
    BLOCKCHAIN_CONNECTION_POINT      = "TODO"
    DISCOVER_CONTRACT                = "TODO"
    MAX_REQUESTS_FOR_RATE_LIMIT_TIME = 1
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
    APPROVER_MAIL         = "dapps-approvals@status.im"
    APPROVE_NOTIFIER_MAIL = "dapps-approvals@status.im"
    /* CloudWatch TODO Once we have logging set up (AWS Cloudwatch) */
    CLOUDWATCH_ACCESS_KEY_ID     = "TODO"
    CLOUDWATCH_REGION            = "TODO"
    CLOUDWATCH_SECRET_ACCESS_KEY = "TODO"
  }
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

  /* Plumbing */
  keypair_name  = aws_key_pair.admin.key_name
  gandi_zone_id = gandi_zone.dap_ps_zone.id
}

module "prod" {
  source     = "./modules/aws-eb-env"
  name       = "prod-dap-ps"
  stage      = "prod"
  env_vars   = local.prod_env
  dns_domain = var.public_domain
  stack_name = var.stack_name

  /* Plumbing */
  keypair_name  = aws_key_pair.admin.key_name
  gandi_zone_id = gandi_zone.dap_ps_zone.id

  /* Scaling */
  instance_type = "t2.micro"
  autoscale_min = 1
  autoscale_max = 6
}
