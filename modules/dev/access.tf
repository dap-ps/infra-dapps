/* ACCESS ---------------------------------------*/

resource "aws_iam_group" "deploy" {
  name   = "${var.name}-deploy"
}

resource "aws_iam_user" "deploy" {
  name = "${var.name}-deploy"
  tags = {
    Description = "User for deploying the ${var.dns_entry}.${var.dns_domain} Elastic Beanstalk app"
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

resource "aws_iam_group_policy_attachment" "deploy" {
  group      = "${aws_iam_group.deploy.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkFullAccess"
}

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

