locals {
  host_suffix      = "${var.zone}.${var.env}.${var.stage}"
  host_full_suffix = "${local.host_suffix}.${var.subdomain}.${var.domain}"
  /* got to add some default groups */
  groups = distinct(concat([var.zone, "${var.env}.${var.stage}"], var.groups))
}

/* the image needs to be queried */
data "aws_ami" "ubuntu" {
  owners = [var.image_owner]

  filter {
    name   = "name"
    values = [var.image_name]
  }
}

resource "aws_security_group" "main" {
  name        = "default-${var.zone}-${var.env}-${var.stage}"
  description = "Allow SSH and other ports. (Terraform)"

  /* unrestricted outging traffic */
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  /* always enable SSH */
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    iterator    = port
    for_each    = var.open_ports
    content {
      from_port = port.value
      to_port   = port.value
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

resource "aws_instance" "main" {
  instance_type     = var.instance_type
  availability_zone = var.zone
  count             = var.host_count

  /* necessary for SSH access */
  associate_public_ip_address = true

  ami               = data.aws_ami.ubuntu.id
  key_name          = var.keypair_name
  security_groups   = [aws_security_group.main.name]

  tags = {
    Name = "node-${format("%02d", count.index+1)}.${local.host_suffix}"
    Fqdn = "node-${format("%02d", count.index+1)}.${local.host_full_suffix}"
  }

  /* bootstraping access for later Ansible use */
  provisioner "ansible" {
    plays {
      playbook {
        file_path = "${path.cwd}/ansible/bootstrap.yml"
      }

      hosts  = [self.public_ip]
      groups = local.groups

      extra_vars = {
        hostname         = self.tags.Name
        ansible_ssh_user = var.ssh_user
        data_center      = var.zone
        env              = var.env
        stage            = var.stage
      }
    }
  }
}

resource "gandi_zonerecord" "main" {
  zone   = var.gandi_zone_id
  name   = "${aws_instance.main[count.index].tags.Name}.${var.subdomain}"
  type   = "A"
  ttl    = 600
  values = [aws_instance.main[count.index].public_ip]
  count  = length(aws_instance.main)
}

/* this adds the host to the Terraform state for Ansible inventory */
resource "ansible_host" "main" {
  inventory_hostname = aws_instance.main[count.index].tags.Name
  groups             = local.groups
  count              = length(aws_instance.main)

  vars = {
    ansible_host = aws_instance.main[count.index].public_ip
    hostname     = aws_instance.main[count.index].tags.Name
    region       = aws_instance.main[count.index].availability_zone
    dns_entry    = aws_instance.main[count.index].tags.Fqdn
    dns_domain   = "${var.subdomain}.${var.domain}"
    data_center  = var.zone
    env          = var.env
    stage        = var.stage
  }
}
