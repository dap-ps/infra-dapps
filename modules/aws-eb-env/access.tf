resource "aws_iam_group" "deploy" {
  name = "${var.name}-deploy"
}

resource "aws_iam_user" "deploy" {
  name = "${var.name}-deploy"

  tags = {
    Description = "User for deploying the ${var.stage}.${var.dns_domain} Elastic Beanstalk app"
  }
}

resource "aws_iam_access_key" "deploy" {
  user    = aws_iam_user.deploy.name
  pgp_key = file("files/support@dap.ps.gpg")
}

resource "aws_iam_user_group_membership" "deploy" {
  user   = aws_iam_user.deploy.name
  groups = [aws_iam_group.deploy.name]
}

/* TODO narrow down these permissions to only deployment */
resource "aws_iam_group_policy_attachment" "deploy" {
  group      = aws_iam_group.deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkFullAccess"
}

/* This doesn't work right now, needs improvement */
//data "aws_region" "current" {}
//data "aws_caller_identity" "current" {}
//data "aws_iam_user" "deploy" {
//  user_name = aws_iam_user.deploy.name
//}
//
///* shorthands for neater templating */
//locals {
//  region           = data.aws_region.current.name
//  account_id       = data.aws_caller_identity.current.account_id
//  instance_profile = module.eb_environment.ec2_instance_profile_role_name
//  full_app_name    = "${var.stage}-${local.app_name}"
//}
//
///* Source: https://gist.github.com/magnetikonline/5034bdbb049181a96ac9 */
//resource "aws_iam_group_policy" "deploy" {
//  name       = "${var.name}-deploy-policy"
//  group      = aws_iam_group.deploy.name
//
//  policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": [
//        "autoscaling:*",
//        "cloudformation:*",
//        "ec2:*"
//      ],
//      "Effect": "Allow",
//      "Resource": ["*"]
//    },
//    {
//      "Action": ["elasticbeanstalk:CreateStorageLocation"],
//      "Effect": "Allow",
//      "Resource": ["*"]
//    },
//    {
//      "Action": ["elasticbeanstalk:*"],
//      "Effect": "Allow",
//      "Resource": [
//        "arn:aws:elasticbeanstalk:*::solutionstack/*",
//        "arn:aws:elasticbeanstalk:${local.region}:${local.account_id}:application/${local.full_app_name}",
//        "arn:aws:elasticbeanstalk:${local.region}:${local.account_id}:applicationversion/${local.full_app_name}/*",
//        "arn:aws:elasticbeanstalk:${local.region}:${local.account_id}:environment/${local.full_app_name}/*",
//        "arn:aws:elasticbeanstalk:${local.region}:${local.account_id}:template/${local.full_app_name}/*"
//      ]
//    },
//    {
//      "Action": ["s3:GetObject"],
//      "Effect": "Allow",
//      "Resource": ["arn:aws:s3:::elasticbeanstalk-*/*"]
//    },
//    {
//      "Action": [
//        "s3:CreateBucket",
//        "s3:DeleteObject",
//        "s3:GetBucketPolicy",
//        "s3:GetObjectAcl",
//        "s3:ListBucket",
//        "s3:PutBucketPolicy",
//        "s3:PutObject",
//        "s3:PutObjectAcl"
//      ],
//      "Effect": "Allow",
//      "Resource": [
//        "arn:aws:s3:::elasticbeanstalk-${local.region}-${local.account_id}",
//        "arn:aws:s3:::elasticbeanstalk-${local.region}-${local.account_id}/*"
//      ]
//    },
//    {
//      "Action": ["iam:PassRole"],
//      "Effect": "Allow",
//      "Resource": ["arn:aws:iam::${local.account_id}:role/${local.instance_profile}"]
//    }
//  ]
//}
//EOF
//}
