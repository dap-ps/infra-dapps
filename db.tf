resource "aws_key_pair" "admin" {
  key_name   = "admin-key"
  public_key = "${file("files/admin.pub")}"
}

data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["${var.image_name}"]
  }

  owners = ["099720109477"]
}

resource "aws_security_group" "mongodb" {
  name = "default-mongodb"
  description = "Allow SSH and MongoDB"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { /* MongoDb port */
    from_port = 27017
    to_port = 27017
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

resource "aws_instance" "mongodb" {
  ami               = "${data.aws_ami.ubuntu.id}"
  instance_type     = "${var.instance_type}"
  key_name          = "${aws_key_pair.admin.key_name}"
  availability_zone = "${var.zone}"

  security_groups = ["${aws_security_group.mongodb.name}"]

  associate_public_ip_address = true

  tags = {
    Name = "node-01.${var.zone}.mongodb.test"
  }

  /* bootstraping access for later Ansible use */
  provisioner "ansible" {
    plays {
      playbook = {
        file_path = "${path.cwd}/ansible/bootstrap.yml"
      }
      groups   = ["${var.group}"]
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

resource "gandi_zonerecord" "mongodb" {
  zone   = "${gandi_zone.dap_ps_zone.id}"
  name   = "${aws_instance.mongodb.tags.Name}.${var.hosts_subdomain}"
  type   = "A"
  ttl    = 600
  values = ["${aws_instance.mongodb.public_ip}"]
}

resource "ansible_host" "main" {
  inventory_hostname = "${aws_instance.mongodb.tags.Name}"
  groups = ["${var.group}", "${var.zone}"]
  vars {
    ansible_host = "${aws_instance.mongodb.public_ip}"
    hostname     = "${aws_instance.mongodb.tags.Name}"
    region       = "${aws_instance.mongodb.availability_zone}"
    dns_entry    = "${aws_instance.mongodb.tags.Name}.${var.hosts_subdomain}.${var.public_domain}"
    dns_domain   = "${var.hosts_subdomain}"
    data_center  = "${var.zone}"
    stage        = "${terraform.workspace}"
    env          = "${var.env}"
  }
}
