/* RESOURCES ------------------------------------*/

resource "aws_key_pair" "admin" {
  key_name   = "admin-key"
  public_key = "${file("admin.pub")}"
}

data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["${var.image_name}"]
  }

  owners = ["099720109477"]
}

resource "aws_security_group" "dap_ps_dev" {
  name = "default-webserver"
  description = "Allow SSH, HTTP and HTTPS"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "dap_ps_dev" {
  ami               = "${data.aws_ami.ubuntu.id}"
  instance_type     = "${var.instance_type}"
  key_name          = "${aws_key_pair.admin.key_name}"
  availability_zone = "${var.zone}"

  security_groups = ["${aws_security_group.dap_ps_dev.name}"]

  associate_public_ip_address = true

  tags = {
    Name = "node-01.${var.zone}.${var.env}.test"
  }

  /* bootstraping access for later Ansible use */
  provisioner "ansible" {
    plays {
      playbook = {
        file_path = "${path.cwd}/ansible/bootstrap.yml"
      }
      groups   = ["dap-ps-dev"]
      extra_vars = {
        hostname         = "node-01.${var.zone}.${var.env}.test"
        ansible_ssh_user = "${var.ssh_user}"
        data_center      = "${var.zone}"
        stage            = "${terraform.workspace}"
        env              = "${var.env}"
      }
    }
  }
}

resource "gandi_zonerecord" "dap_ps_dev" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "${aws_instance.dap_ps_dev.tags.Name}.${var.hosts_subdomain}"
  type   = "A"
  ttl    = 3600
  values = ["${aws_instance.dap_ps_dev.public_ip}"]
}

resource "gandi_zonerecord" "main" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "dev"
  type   = "A"
  ttl    = 3600
  values = ["${aws_instance.dap_ps_dev.public_ip}"]
}
