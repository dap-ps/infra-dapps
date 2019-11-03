variable "name" {
  description = "Name of this environment to be used in all resources."
  type        = string
}

variable "stage" {
  description = "Name of stage, used for DNS entry for this environment."
  type        = string
}

variable "gandi_zone_id" {
  description = "ID of the zone in Gandi DNS registrar."
  type        = string
}

variable "dns_domain" {
  description = "Name of domain for this environment."
  type        = string
}

variable "stack_name" {
  description = "Name of application stack for ElasticBeanstalk."
  type        = string
}

variable "keypair_name" {
  description = "Name of the AWS key pair for SSH access."
  type        = string
}

variable "max_availability_zones" {
  description = "Maximum number of availability zones that can be used in Subnet."
  default     = 2
  type        = number
}

variable "env_vars" {
  description = "Environment variables to be defined in the ElasticBeanstalk environment."
  type        = map(string)
}

/* Scaling --------------------------------------*/

variable "instance_type" {
  description = "Name of instance type to use"
  default     = "t2.micro"
  type        = string
}

variable "autoscale_min" {
  description = "Minimum instances autoscaling will create."
  default     = "1"
  type        = string
}

variable "autoscale_max" {
  description = "Maximum instances autoscaling will create."
  default     = "2"
  type        = string
}
