/* SMTP Cerdentials -----------------------------*/

/**
 * For more details see:
 * https://docs.aws.amazon.com/ses/latest/DeveloperGuide/smtp-connect.html
 **/

resource "aws_iam_user" "smtp" {
  name = "ses-smtp-user.dap-ps"
}

resource "aws_iam_access_key" "smtp" {
  user    = aws_iam_user.smtp.name
  pgp_key = file("files/support@dap.ps.gpg")
}

resource "aws_iam_policy" "smtp" {
  name        = "AmazonSesSendingAccess"
  description = "Policy that gives Write access to SES Sending"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ses:SendRawEmail",
            "Resource": "*"
        }
    ]
}
EOF

}

resource "aws_iam_user_policy_attachment" "smtp" {
  user = aws_iam_user.smtp.name
  policy_arn = aws_iam_policy.smtp.arn
}
