/* ACCESS ---------------------------------------*/

resource "aws_iam_group" "deploy" {
  name   = "dev-dap-ps-deploy"
}

resource "aws_iam_user" "deploy" {
  name = "dap-ps-deploy"
  tags = {
    Description = "User for deploying the dap.ps Elastic Beanstalk app"
  }
}

resource "aws_iam_user_group_membership" "deploy" {
  user   = "${aws_iam_user.deploy.name}"
  groups = ["${aws_iam_group.deploy.name}"]
}

resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                        "s3:GetBucketLocation",
                        "s3:ListAllMyBuckets"
                      ],
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.dev_dap_ps.id}",
                "arn:aws:s3:::${aws_s3_bucket.dev_dap_ps.id}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "deploy" {
  name       = "deploy-policy-attachment"
  users      = ["${aws_iam_user.deploy.name}"]
  groups     = ["${aws_iam_group.deploy.name}"]
  policy_arn = "${aws_iam_policy.policy.arn}"
}

/* RESOURCES ------------------------------------*/

resource "aws_s3_bucket" "dev_dap_ps" {
  bucket = "${var.dap_ps_app_bucket_name}"
  acl    = "private"

  tags = {
    Name = "dev.dap.ps application bucket"
  }
}

resource "aws_s3_bucket_object" "dev_dap_ps" {
  bucket = "${aws_s3_bucket.dev_dap_ps.id}"
  key    = "dapps.zip"
  source = "files/dapps.zip"
}

resource "aws_elastic_beanstalk_application" "dev_dap_ps" {
  name        = "dev-dap-ps-app"
  description = "dev.dap.ps application"
}

resource "aws_elastic_beanstalk_application_version" "dev_dap_ps" {
  name        = "dev-dap-ps-app"
  description = "dev.dap.ps application version (Terraform)"
  application = "${aws_elastic_beanstalk_application.dev_dap_ps.name}"
  bucket      = "${aws_s3_bucket.dev_dap_ps.id}"
  key         = "${aws_s3_bucket_object.dev_dap_ps.id}"
}

resource "aws_elastic_beanstalk_environment" "dev_dap_ps" {
  name                = "dev-dap-ps-app"
  application         = "${aws_elastic_beanstalk_application.dev_dap_ps.name}"
  solution_stack_name = "64bit Amazon Linux 2018.03 v4.8.3 running Node.js"
}
