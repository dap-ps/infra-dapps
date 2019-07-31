/* IMAGE ----------------------------------------*/

variable "image_name" {
  description = "Name of AMI image to use."
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20190212.1"
}

variable "image_owner" {
  description = "ID of the owner of AMI image."
  type        = string
  default     = "099720109477"
}

variable "ssh_user" {
  description = "User used for SSH access."
  type        = string
  default     = "ubuntu"
}

/* HOSTING --------------------------------------*/

variable "zone" {
  description = "Name of availability zone to deploy to."
  type        = string
  default     = "us-east-1a"
}

variable "subdomain" {
  description = "Subdomain for hosts entries."
  type        = string
}

variable "domain" {
  description = "Public DNS Domain address"
  type        = string
}

variable "open_ports" {
  description = "Which ports should be opened on the firewal."
  type        = list(number)
}

variable "keypair_name" {
  description = "Name of SSH key pair in AWS."
  type        = string
}

/* DNS ------------------------------------------*/

variable "gandi_zone_id" {
  description = "ID of the zone in Gandi DNS registrar."
  type        = string
}

/* SCALING --------------------------------------*/

variable "host_count" {
  description = "Number of instances to create."
  type        = number
}

variable "instance_type" {
  description = "Name of instance type to use"
  type        = string
  default     = "t2.micro"
}

/* SPECIFIC -------------------------------------*/

variable "groups" {
  description = "Name of Ansible group"
  type        = list(string)
}

variable "env" {
  description = "Name of environment to create"
  type        = string
}

variable "stage" {
  description = "Name of stage, like prod, dev, or staging."
  type        = string
}
