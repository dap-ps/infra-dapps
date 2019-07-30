locals {
  dev_env = {
    /* WARNING EB forces PORT 8081 */
    ENVIRONMENT     = "DEV"
    RATE_LIMIT_TIME = 15

    /* Access */
    ADMIN_USER     = "${var.dap_ps_admin_user}"
    ADMIN_PASSWORD = "${var.dap_ps_admin_pass}"

    /* Database */
    DB_CONNECTION = "${var.dap_ps_db_uri}"

    /* BlockChain */
    BLOCKCHAIN_CONNECTION_POINT      = "wss://ropsten.infura.io/ws/v3/8675214b97b44e96b70d05326c61fd6a"
    DISCOVER_CONTRACT                = "0x17e7a7330d23fc6a2ab8578a627408f815396662"
    MAX_REQUESTS_FOR_RATE_LIMIT_TIME = 1

    /* IPFS */
    IPFS_HOST     = "ipfs.infura.io"
    IPFS_PORT     = 5001
    IPFS_PROTOCOL = "https"

    /* Email */
    EMAIL_USER            = "${var.dap_ps_smtp_user}"
    EMAIL_PASSWORD        = "${var.dap_ps_smtp_pass}"
    EMAIL_HOST            = "email-smtp.us-east-1.amazonaws.com"
    EMAIL_PORT            = 465
    EMAIL_TLS             = "true"
    APPROVER_MAIL         = "dapps-approvals@status.im"
    APPROVE_NOTIFIER_MAIL = "dapps-approvals@status.im"

    /* CloudWatch TODO */
    CLOUDWATCH_ACCESS_KEY_ID     = "This is for production, if you have logging set up (AWS Cloudwatch)"
    CLOUDWATCH_REGION            = "This is for production, if you have logging set up (AWS Cloudwatch)"
    CLOUDWATCH_SECRET_ACCESS_KEY = "This is for production, if you have logging set up (AWS Cloudwatch)"
  }
}

module "dev" {
  source        = "./modules/aws-eb-env"
  name          = "dev-dap-ps"
  gandi_zone_id = "${gandi_zone.dap_ps_zone.id}"
  dns_domain    = "dap.ps"
  stage         = "dev"
  stack_name    = "${var.stack_name}"
  keypair_name  = "${aws_key_pair.admin.key_name}"

  /* Scaling */
  autoscale_min = 1
  autoscale_max = 2

  /* Environment */
  env_vars = "${local.dev_env}"
}
