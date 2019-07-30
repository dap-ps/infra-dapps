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

resource "aws_iam_group_policy_attachment" "deploy" {
  group      = aws_iam_group.deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkFullAccess"
}
