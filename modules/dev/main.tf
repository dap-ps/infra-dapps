/* ACCESS ---------------------------------------*/

resource "aws_iam_group" "deploy" {
  name   = "${var.name}-deploy"
}

resource "aws_iam_user" "deploy" {
  name = "${var.name}-deploy"
  tags = {
    Description = "User for deploying the dap.ps Elastic Beanstalk app"
  }
}

resource "aws_iam_access_key" "deploy" {
  user    = "${aws_iam_user.deploy.name}"
  pgp_key = "${file("files/support@dap.ps.gpg")}"
}

resource "aws_iam_user_group_membership" "deploy" {
  user   = "${aws_iam_user.deploy.name}"
  groups = ["${aws_iam_group.deploy.name}"]
}

resource "aws_iam_policy_attachment" "deploy" {
  name       = "deploy-policy-attachment"
  groups     = ["${aws_iam_group.deploy.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkFullAccess"
}

/**
 * Uncomment this if you want to extract the secret again.
 * For details see: https://www.terraform.io/docs/providers/aws/r/iam_access_key.html
output "deploy_access_key" {
  value = "${aws_iam_access_key.deploy.id}"
}
output "deploy_secret_key" {
  value = "${aws_iam_access_key.deploy.encrypted_secret}"
}
*/

/* ROLES ----------------------------------------*/

resource "aws_iam_instance_profile" "main" {
  name  = "${var.name}"
  role = "${aws_iam_role.main.name}"
}

resource "aws_iam_role" "main" {
  name = "${var.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "AWSElasticBeanstalkWebTier" {
  name       = "${var.name}-AWSElasticBeanstalkWebTier"
  roles      = ["${aws_iam_role.main.name}"]
  policy_arn ="arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
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
