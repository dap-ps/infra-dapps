/* Validated Domain -----------------------------*/

resource "aws_ses_domain_identity" "dap_ps" {
  domain = var.public_domain
}

resource "aws_ses_domain_dkim" "dap_ps" {
  domain = aws_ses_domain_identity.dap_ps.domain
}

resource "aws_ses_domain_mail_from" "dap_ps" {
  domain           = aws_ses_domain_identity.dap_ps.domain
  mail_from_domain = "mail.${aws_ses_domain_identity.dap_ps.domain}"
}

resource "gandi_zonerecord" "dap_ps_verification" {
  zone   = gandi_zone.dap_ps_zone.id
  name   = "_amazonses"
  type   = "TXT"
  ttl    = 3600
  values = ["\"${aws_ses_domain_identity.dap_ps.verification_token}\""]
}

resource "gandi_zonerecord" "dap_ps_mail_mx" {
  zone   = gandi_zone.dap_ps_zone.id
  name   = "mail"
  type   = "MX"
  ttl    = 3600
  values = ["10 feedback-smtp.us-east-1.amazonses.com."]
}

resource "gandi_zonerecord" "dap_ps_mail_spf" {
  zone   = gandi_zone.dap_ps_zone.id
  name   = "mail"
  type   = "TXT"
  ttl    = 3600
  values = ["\"v= spf1 include:amazonses.com ~all\""]
}

resource "gandi_zonerecord" "dap_ps_dkim" {
  zone   = gandi_zone.dap_ps_zone.id
  ttl    = 3600
  type   = "CNAME"
  count  = 3
  name   = "${element(aws_ses_domain_dkim.dap_ps.dkim_tokens, count.index)}._domainkey"
  values = ["${element(aws_ses_domain_dkim.dap_ps.dkim_tokens, count.index)}.dkim.amazonses.com."]
}

/* SES EMail Fowarding --------------------------*/

resource "gandi_zonerecord" "dap_ps_mx" {
  zone   = gandi_zone.dap_ps_zone.id
  name   = "@"
  type   = "MX"
  ttl    = 3600
  values = ["10 inbound-smtp.us-east-1.amazonaws.com."]
}

/* Validated Emails -----------------------------*/

resource "aws_ses_email_identity" "jakub" {
  email = "jakub@status.im"
}

resource "aws_ses_email_identity" "andy" {
  email = "andy@status.im"
}

