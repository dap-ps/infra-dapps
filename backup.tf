/* Prod EBS Backups -----------------------------*/

resource "aws_iam_role" "prod_snapshots" {
  name = "dap-ps-prod-snapshots-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dlm.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "prod_snapshots" {
  name = "dap-ps-prod-snapshots-policy"
  role = aws_iam_role.prod_snapshots.id

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateSnapshot",
            "ec2:DeleteSnapshot",
            "ec2:DescribeVolumes",
            "ec2:DescribeSnapshots"
         ],
         "Resource": "*"
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateTags"
         ],
         "Resource": "arn:aws:ec2:*::snapshot/*"
      }
   ]
}
EOF
}

resource "aws_dlm_lifecycle_policy" "prod_snapshots" {
  description        = "dap-ps prod DB DLM lifecycle policy"
  execution_role_arn = aws_iam_role.prod_snapshots.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "one week of daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["23:45"]
      }

      retain_rule {
        count = 7
      }

      tags_to_add = {
        Source = "DLM lifecycle policy"
      }

      copy_tags = true
    }

    target_tags = {
      Fleet = "db.prod"
    }
  }
}
