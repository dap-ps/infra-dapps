data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = [var.image_name]
  }

  owners = ["099720109477"]
}

resource "aws_security_group" "mongodb" {
  name        = "default-mongodb"
  description = "Allow SSH and MongoDB"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 27017 /* MongoDb port */
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "mongodb" {
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.instance_type
  key_name          = aws_key_pair.admin.key_name
  availability_zone = var.zone

  security_groups = [aws_security_group.mongodb.name]

  associate_public_ip_address = true

  tags = {
    Name = "node-01.${var.zone}.mongodb.test"
  }

  /* bootstraping access for later Ansible use */
  /* bootstraping access for later Ansible use */
  provisioner "ansible" {
    plays {
      playbook {
        file_path = "${path.cwd}/ansible/bootstrap.yml"
      }

      groups = [var.group]

      extra_vars = {
        hostname         = "node-01.${var.zone}.mongodb.test"
        ansible_ssh_user = var.ssh_user
        data_center      = var.zone
        stage            = terraform.workspace
        env              = var.env
      }
    }
  }
}

resource "gandi_zonerecord" "mongodb" {
  zone   = gandi_zone.dap_ps_zone.id
  name   = "${aws_instance.mongodb.tags.Name}.${var.hosts_subdomain}"
  type   = "A"
  ttl    = 600
  values = [aws_instance.mongodb.public_ip]
}

resource "ansible_host" "main" {
  inventory_hostname = aws_instance.mongodb.tags.Name
  groups             = ["mongodb", var.group, var.zone]

  vars = {
    ansible_host = aws_instance.mongodb.public_ip
    hostname     = aws_instance.mongodb.tags.Name
    region       = aws_instance.mongodb.availability_zone
    dns_entry    = "${aws_instance.mongodb.tags.Name}.${var.hosts_subdomain}.${var.public_domain}"
    dns_domain   = var.hosts_subdomain
    data_center  = var.zone
    stage        = terraform.workspace
    env          = var.env
  }
}

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

/**
 * Uncomment this if you want to extract the secret again.
 * For details see: https://www.terraform.io/docs/providers/aws/r/iam_access_key.html
output "mongodb_s3_access_key" {
  value = "${aws_iam_access_key.mongodb_backup.id}"
}
output "mongodb_s3_secret_key" {
  value = "${aws_iam_access_key.mongodb_backup.encrypted_secret}"
}
*/
