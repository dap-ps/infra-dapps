/* Gandi DNS ------------------------------------*/

resource "gandi_zone" "dap_ps_zone" {
  name = "${var.public_domain} zone"
}

resource "gandi_domainattachment" "dap_ps" {
  domain = "${var.public_domain}"
  zone   = "${gandi_zone.dap_ps_zone.id}"
}

/* SES EMail Fowarding --------------------------*/

resource "gandi_zonerecord" "dap_ps_mx" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "@"
  type   = "MX"
  ttl    = 3600
  values = ["10 inbound-smtp.us-east-1.amazonaws.com."]
}

/* MAIL SITE ------------------------------------*/

/**
 * This is the main site hosted on GitHub:
 * https://github.com/dap-ps/discover
 **/
resource "gandi_zonerecord" "dap_ps_site" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "@"
  type   = "A"
  ttl    = 3600
  values = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ]
}
