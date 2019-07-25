variable "name" {
  description = "Name of this environment to be used in all resources."
}

variable "gandi_zone_id" {
  description = "ID of the zone in Gandi DNS registrar."
}

variable "dns_domain" {
  description = "Name of domain for this environment."
}

variable "dns_entry" {
  description = "Name of DNS entry for this environment."
}
