locals {
  dev_env = {
    /* WARNING EB forces PORT 8081 */
    ENVIRONMENT        = "DEV"
    RATE_LIMIT_TIME    = 15 /* ms window */
    RATE_LIMIT_MAX_REQ = 1
    /* Access */
    ADMIN_USER     = var.dap_ps_admin_user
    ADMIN_PASSWORD = var.dap_ps_admin_pass
    /* Database */
    DB_CONNECTION = var.dap_ps_dev_db_uri
    /* Blockchain */
    BLOCKCHAIN_CONNECTION_POINT      = "wss://ropsten.infura.io/ws/v3/8675214b97b44e96b70d05326c61fd6a"
    DISCOVER_CONTRACT                = "0x9fb115BC152aE21ECDc81c73843673fa38e4D2dB"
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
  }
}

module "dev_db_bucket" {
  source      = "./modules/aws-s3-bucket"
  bucket_name = "dev-dap-ps-db-backups"
  description = "Bucket for MongoDB backups on db.dev"
}

module "dev_db" {
  source     = "./modules/aws-ec2-instance"
  groups     = ["mongodb"]
  env        = "db"
  stage      = "dev"
  host_count = 1
  subdomain  = var.hosts_subdomain
  domain     = var.public_domain
  open_ports = [27017] /* mongodb */

  /* Plumbing */
  keypair_name  = aws_key_pair.admin.key_name
  gandi_zone_id = gandi_zone.dap_ps_zone.id
}

module "dev_env" {
  source     = "./modules/aws-eb-env"
  name       = "dev-dap-ps"
  stage      = "dev"
  env_vars   = local.dev_env
  dns_domain = var.public_domain
  stack_name = var.stack_name

  /* Plumbing */
  keypair_name  = aws_key_pair.admin.key_name
  gandi_zone_id = gandi_zone.dap_ps_zone.id

  /* Scaling */
  instance_type = "t3.small"
  autoscale_min = 1
  autoscale_max = 2
}
