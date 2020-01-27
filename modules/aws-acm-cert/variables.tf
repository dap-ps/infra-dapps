variable "stage" {
  description = "Name of stage, used for DNS entry for this environment."
  type        = string
}

variable "domain" {
  description = "Name of domain for this environment."
  type        = string
}

variable "zone_id" {
  description = "ID of the zone in AWS Route53."
  type        = string
}

variable "sans" {
  description = "List of Subject Alternative Names."
  type        = list(string)
  default    = []
}

variable "route53_zone_id" {
  description = "ID of the zone in AWS Route53."
  type        = string
}
