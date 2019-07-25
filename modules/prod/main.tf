/* SSL Certificate ------------------------------*/

resource "aws_acm_certificate" "prod" {
  domain_name       = "${var.dns_domain}"
  validation_method = "DNS"
}

resource "gandi_zonerecord" "prod_cert_verification" {
  zone   = "${var.gandi_zone_id}"
  name   = "${replace(aws_acm_certificate.prod.domain_validation_options.0.resource_record_name, ".${var.dns_domain}.", "")}"
  type   = "${aws_acm_certificate.prod.domain_validation_options.0.resource_record_type}"
  ttl    = 300
  values = ["${aws_acm_certificate.prod.domain_validation_options.0.resource_record_value}"]
}

resource "aws_acm_certificate_validation" "prod" {
  certificate_arn         = "${aws_acm_certificate.prod.arn}"
  validation_record_fqdns = ["${gandi_zonerecord.prod_cert_verification.name}.${var.dns_domain}"]
}
