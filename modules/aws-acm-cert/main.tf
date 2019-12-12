resource "aws_acm_certificate" "main" {
  domain_name = "${var.stage}.${var.domain}"

  subject_alternative_names = sort(var.sans)
  validation_method         = "DNS"

  tags = {
    Name = "${var.stage}.${var.domain}"
  }
}

resource "gandi_zonerecord" "cert_verification" {
  zone   = var.zone_id
  name   = replace(aws_acm_certificate.main.domain_validation_options[count.index].resource_record_name, ".${var.domain}.", "")
  type   = aws_acm_certificate.main.domain_validation_options[count.index].resource_record_type
  ttl    = 300
  values = [aws_acm_certificate.main.domain_validation_options[count.index].resource_record_value]
  count  = length(var.sans)+1
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [
    for verification in gandi_zonerecord.cert_verification:
    "${verification.name}.${var.domain}"
  ]
}
