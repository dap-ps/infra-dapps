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

/* RESOURCES ------------------------------------*/

resource "aws_elastic_beanstalk_application" "dev_dap_ps" {
  name        = "dev-dap-ps-app"
  description = "dev.dap.ps application"
}

resource "aws_elastic_beanstalk_environment" "dev_dap_ps" {
  name                = "dev-dap-ps-app"
  application         = "${aws_elastic_beanstalk_application.dev_dap_ps.name}"
  solution_stack_name = "64bit Amazon Linux 2018.03 v4.8.3 running Node.js"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = "${aws_iam_instance_profile.main.name}"
  }
}

/* DNS ------------------------------------------*/

resource "gandi_zonerecord" "dev_dap_ps_site" {
  zone   = "${var.gandi_zone_id}"
  name   = "${var.dns_entry}"
  type   = "CNAME"
  ttl    = 3600
  values = ["${aws_elastic_beanstalk_environment.dev_dap_ps.cname}."]
}
