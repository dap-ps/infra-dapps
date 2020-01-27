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

resource "aws_route53_record" "dap_ps_verification" {
  zone_id = aws_route53_zone.dap_ps.zone_id
  name    = "_amazonses"
  type    = "TXT"
  ttl     = 3600
  records = ["${aws_ses_domain_identity.dap_ps.verification_token}"]
}

resource "aws_route53_record" "dap_ps_mail_mx" {
  zone_id = aws_route53_zone.dap_ps.zone_id
  name    = "mail"
  type    = "MX"
  ttl     = 3600
  records = ["10 feedback-smtp.us-east-1.amazonses.com."]
}

resource "aws_route53_record" "dap_ps_mail_spf" {
  zone_id = aws_route53_zone.dap_ps.zone_id
  name    = "mail"
  type    = "TXT"
  ttl     = 3600
  records = ["v= spf1 include:amazonses.com ~all"]
}

resource "aws_route53_record" "dap_ps_dkim" {
  zone_id = aws_route53_zone.dap_ps.zone_id
  ttl     = 3600
  type    = "CNAME"
  count   = 3
  name    = "${element(aws_ses_domain_dkim.dap_ps.dkim_tokens, count.index)}._domainkey"
  records = ["${element(aws_ses_domain_dkim.dap_ps.dkim_tokens, count.index)}.dkim.amazonses.com."]
}

/* SES EMail Fowarding --------------------------*/

resource "aws_route53_record" "dap_ps_mx" {
  zone_id = aws_route53_zone.dap_ps.zone_id
  name    = "@"
  type    = "MX"
  ttl     = 3600
  records = ["10 inbound-smtp.us-east-1.amazonaws.com."]
}

/* Validated Emails -----------------------------*/

resource "aws_ses_email_identity" "jakub" {
  email = "jakub@status.im"
}

resource "aws_ses_email_identity" "andy" {
  email = "andy@status.im"
}
