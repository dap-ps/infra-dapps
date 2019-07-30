resource "aws_acm_certificate" "main" {
  domain_name = "${var.stage}.${var.dns_domain}"

  /* TODO support SAN of dap.ps */
  subject_alternative_names = []
  validation_method         = "DNS"
}

resource "gandi_zonerecord" "cert_verification" {
  zone = var.gandi_zone_id
  name = replace(aws_acm_certificate.main.domain_validation_options[0].resource_record_name, ".${var.dns_domain}.", "")
  type   = aws_acm_certificate.main.domain_validation_options[0].resource_record_type
  ttl    = 300
  values = [aws_acm_certificate.main.domain_validation_options[0].resource_record_value]
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = ["${gandi_zonerecord.cert_verification.name}.${var.dns_domain}"]
}
