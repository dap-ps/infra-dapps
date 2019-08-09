locals {
  cert_sans = [var.dns_domain]
}

resource "aws_acm_certificate" "main" {
  domain_name = "${var.stage}.${var.dns_domain}"

  subject_alternative_names = local.cert_sans
  validation_method         = "DNS"

  tags = {
    Name = "${var.stage}.${var.dns_domain}"
  }
}

resource "gandi_zonerecord" "cert_verification" {
  zone   = var.gandi_zone_id
  name   = replace(aws_acm_certificate.main.domain_validation_options[count.index].resource_record_name, ".${var.dns_domain}.", "")
  type   = aws_acm_certificate.main.domain_validation_options[count.index].resource_record_type
  ttl    = 300
  values = [aws_acm_certificate.main.domain_validation_options[count.index].resource_record_value]
  count  = length(local.cert_sans)+1
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [
    for verification in gandi_zonerecord.cert_verification:
    "${verification.name}.${var.dns_domain}"
  ]
}
