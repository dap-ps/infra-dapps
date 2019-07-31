resource "aws_iam_user" "main" {
  name = var.bucket_name

  tags = {
    Description = "User for ${var.bucket_name} S3 bucket"
  }
}

resource "aws_iam_access_key" "main" {
  user    = aws_iam_user.main.name
  pgp_key = file("files/support@dap.ps.gpg")
}

resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  acl    = "private"

  tags = {
    Name = var.bucket_name
    Desc = var.description
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS": ["${aws_iam_user.main.arn}"]},
      "Action": ["s3:*"],
      "Resource":["arn:aws:s3:::${var.bucket_name}/*"]
    }
  ]
}
EOF

}
