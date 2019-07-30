/**
 * For more details on this setup see:
 * https://github.com/arithmetric/aws-lambda-ses-forwarder
 **/

/* SES S3 Bucket --------------------------------*/

data "aws_caller_identity" "current" {
}

resource "aws_s3_bucket" "ses-forwarder-emails" {
  bucket = "ses-forwarder-emails"
  acl    = "private"

  tags = {
    Name = "Emails Managed by SES Forwarder Lambda function"
  }

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Sid": "GiveSESPermissionToWriteEmail",
         "Effect": "Allow",
         "Principal": {
            "Service": "ses.amazonaws.com"
         },
         "Action": "s3:PutObject",
         "Resource": "arn:aws:s3:::${var.ses_forwarder_bucket_name}/*",
         "Condition": {
            "StringEquals": {
               "aws:Referer": "${data.aws_caller_identity.current.account_id}"
            }
         }
      }
   ]
}
EOF


  lifecycle {
    prevent_destroy = true
  }
}

/* SES Configuration --------------------------------*/

resource "aws_iam_role" "ses_lambda_role" {
  name = "LambdaSesForwarder"

  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
   ]
}
EOF

}

resource "aws_iam_role_policy" "ses_lambda_policy" {
name = "LambdaSesForwarderPolicy"
role = aws_iam_role.ses_lambda_role.id

policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
         "Resource": "arn:aws:logs:*:*:*"
      },
      {
         "Effect": "Allow",
         "Action": "ses:SendRawEmail",
         "Resource": "*"
      },
      {
         "Effect": "Allow",
         "Action": ["s3:GetObject", "s3:PutObject"],
         "Resource": "arn:aws:s3:::${var.ses_forwarder_bucket_name}/*"
      }
   ]
}
EOF

}

data "archive_file" "ses_forwarder" {
type = "zip"
source_file = "files/index.js"
output_path = "files/sesforwarder.zip"
}

resource "aws_lambda_function" "ses_forwarder" {
filename = "files/sesforwarder.zip"
source_code_hash = data.archive_file.ses_forwarder.output_base64sha256

function_name = "SesForwarder"
role = aws_iam_role.ses_lambda_role.arn
handler = "index.handler"
runtime = "nodejs8.10"
memory_size = 128
timeout = 10
}

resource "aws_lambda_permission" "allow_ses" {
statement_id = "AllowExecutionFromSES"
action = "lambda:InvokeFunction"
function_name = aws_lambda_function.ses_forwarder.function_name
principal = "ses.amazonaws.com"
}

resource "aws_ses_receipt_rule" "ses_forwarder" {
name = "SesForwarder"
rule_set_name = "default-rule-set"
enabled = true
scan_enabled = true

s3_action {
bucket_name = var.ses_forwarder_bucket_name
object_key_prefix = "${var.public_domain}/"
position = 1
}

lambda_action {
function_arn = aws_lambda_function.ses_forwarder.arn
invocation_type = "Event"
position = 2
}
}

