/* S3 BACKUPS BUCKET ----------------------------*/

resource "aws_iam_user" "mongodb_backup" {
  name = "mongodb-backups"

  tags = {
    Description = "User for S3 MongoDB backups"
  }
}

resource "aws_iam_access_key" "mongodb_backup" {
  user    = aws_iam_user.mongodb_backup.name
  pgp_key = file("files/support@dap.ps.gpg")
}

resource "aws_s3_bucket" "mongodb_backup" {
  bucket = "dev-dap-ps-mongodb-backups"
  acl    = "private"

  tags = {
    Name = "Bucket for MongoDB backups"
  }

  lifecycle {
    prevent_destroy = true
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS": ["${aws_iam_user.mongodb_backup.arn}"]},
      "Action": ["s3:PutObject","s3:PutObjectAcl"],
      "Resource":["arn:aws:s3:::dev-dap-ps-mongodb-backups/*"]
    }
  ]
}
EOF

}
