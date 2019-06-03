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

resource "aws_iam_policy_attachment" "deploy" {
  name       = "deploy-policy-attachment"
  groups     = ["${aws_iam_group.deploy.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkFullAccess"
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
}
