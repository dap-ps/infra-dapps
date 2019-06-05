/* SMTP Cerdentials -----------------------------*/

resource "aws_iam_user" "smtp" {
  name = "ses-smtp-user.dap-ps"
}

resource "aws_iam_access_key" "smtp" {
  user    = "${aws_iam_user.smtp.name}"
  pgp_key = "${file("files/support@dap.ps.gpg")}"
}

resource "aws_iam_policy" "smtp" {
  name        = "AmazonSesSendingAccess"
  description = "Policy that gives Write access to SES Sending"
  policy      = <<EOF
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
  user       = "${aws_iam_user.smtp.name}"
  policy_arn = "${aws_iam_policy.smtp.arn}"
}

/**
 * Uncomment this if you want to extract the secret again.
 * For details see: https://www.terraform.io/docs/providers/aws/r/iam_access_key.html
output "smtp_access_key" {
  value = "${aws_iam_access_key.smtp.id}"
}
output "smtp_secret_key" {
  value = "${aws_iam_access_key.smtp.encrypted_secret}"
}
*/
