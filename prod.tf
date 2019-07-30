module "prod" {
  source        = "./modules/prod"
  name          = "prod-dap-ps"
  gandi_zone_id = "${gandi_zone.dap_ps_zone.id}"
  dns_domain    = "dap.ps"
  dns_entry     = "prod"                         /* just means use `dap.ps` */
}
