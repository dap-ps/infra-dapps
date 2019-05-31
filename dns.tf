/* Gandi DNS ------------------------------------*/

resource "gandi_zone" "dap_ps_zone" {
  name = "${var.public_domain} zone"
}

resource "gandi_domainattachment" "dap_ps" {
  domain = "${var.public_domain}"
  zone   = "${gandi_zone.dap_ps_zone.id}"
}

/* SES EMail Fowarding --------------------------*/

resource "gandi_zonerecord" "domain-verification" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "_amazonses"
  type   = "TXT"
  ttl    = 3600
  values = ["\"ay9a+52dCvn0fJb9YMTQXHeGf3SL3/l3vxWXCDjzJzY=\""]
}

resource "gandi_zonerecord" "dap_ps_dkim_1" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "mnkff5wcdz6ce7rzzcsu3lnapq6kfmmn._domainkey"
  type   = "CNAME"
  ttl    = 3600
  values = ["mnkff5wcdz6ce7rzzcsu3lnapq6kfmmn.dkim.amazonses.com."]
}

resource "gandi_zonerecord" "dap_ps_dkim_2" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "mnd3y3oanybpyjpirxkag43nvxlk2xeh._domainkey"
  type   = "CNAME"
  ttl    = 3600
  values = ["mnd3y3oanybpyjpirxkag43nvxlk2xeh.dkim.amazonses.com."]
}

resource "gandi_zonerecord" "dap_ps_dkim_3" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "ldcpr3o4ktcsswfx5bc7t5plr6pvnxfj._domainkey"
  type   = "CNAME"
  ttl    = 3600
  values = ["ldcpr3o4ktcsswfx5bc7t5plr6pvnxfj.dkim.amazonses.com."]
}

resource "gandi_zonerecord" "dap_ps_mx" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "@"
  type   = "MX"
  ttl    = 3600
  values = ["10 inbound-smtp.eu-east-1.amazonaws.com."]
}

resource "gandi_zonerecord" "dap_ps_mail_mx" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "mail"
  type   = "MX"
  ttl    = 3600
  values = ["10 feedback-smtp.eu-west-1.amazonses.com"]
}

resource "gandi_zonerecord" "dap_ps_mail_spf" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "mail"
  type   = "TXT"
  ttl    = 3600
  values = ["\"v= spf1 include:amazonses.com ~all\""]
}

/* MAIL SITE ------------------------------------*/

/* This is the main site hosted on GitHub */
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
