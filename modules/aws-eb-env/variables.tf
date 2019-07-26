variable "name" {
  description = "Name of this environment to be used in all resources."
}

variable "stage" {
  description = "Name of stage, used for DNS entry for this environment."
}

variable "gandi_zone_id" {
  description = "ID of the zone in Gandi DNS registrar."
}

variable "dns_domain" {
  description = "Name of domain for this environment."
}

variable "stack_name" {
  description = "Name of application stack for ElasticBeanstalk."
}

variable "keypair_name" {
  description = "Name of the AWS key pair for SSH access."
}

variable "max_availability_zones" {
  description = "Maximum number of availability zones that can be used in Subnet."
  default     = "2"
}
