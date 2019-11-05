variable "stage" {
  description = "Name of stage, used for DNS entry for this environment."
  type        = string
}

variable "domain" {
  description = "Name of domain for this environment."
  type        = string
}

variable "zone_id" {
  description = "ID of the zone in Gandi DNS registrar."
  type        = string
}

variable "sans" {
  description = "List of Subject Alternative Names."
  type        = list(string)
  default    = []
}
