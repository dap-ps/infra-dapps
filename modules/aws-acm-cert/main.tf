resource "aws_acm_certificate" "main" {
  domain_name = "${var.stage}.${var.domain}"

  subject_alternative_names = reverse(sort(var.sans))
  validation_method         = "DNS"

  tags = {
    Name = "${var.stage}.${var.domain}"
  }
}

resource "aws_route53_record" "cert_verification" {
  zone_id = var.zone_id
  name    = replace(tolist(aws_acm_certificate.main.domain_validation_options)[count.index].resource_record_name, ".${var.domain}.", "")
  type    = tolist(aws_acm_certificate.main.domain_validation_options)[count.index].resource_record_type
  ttl     = 300
  records = [tolist(aws_acm_certificate.main.domain_validation_options)[count.index].resource_record_value]
  count   = length(aws_acm_certificate.main.domain_validation_options)
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [
    for verification in aws_route53_record.cert_verification:
    "${verification.name}.${var.domain}"
  ]
}
