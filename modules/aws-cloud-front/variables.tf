variable "env" {
  description = "Name of the environment"
  type        = string
  default     = ""
}

variable "stage" {
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  type        = string
  default     = ""
}

variable "comment" {
  type        = string
  default     = "Managed by Terraform"
  description = "Comment for the origin access identity"
}

variable "aliases" {
  type        = list(string)
  description = "List of FQDN's - Used to set the Alternate Domain Names (CNAMEs) setting on Cloudfront"
  default     = []
}

variable "cert_arn" {
  type        = string
  description = "Existing ACM Certificate ARN"
}

variable "minimum_protocol_version" {
  type        = string
  description = "Cloudfront TLS minimum protocol version"
  default     = "TLSv1"
}

variable "origin_force_destroy" {
  type        = bool
  default     = false
  description = "Delete all objects from the bucket  so that the bucket can be destroyed without error (e.g. `true` or `false`)"
}

variable "price_class" {
  type        = string
  default     = "PriceClass_200"
  description = "Price class for this distribution: `PriceClass_All`, `PriceClass_200`, `PriceClass_100`"
  # https://aws.amazon.com/fr/cloudfront/pricing/
}

/* Origin */

variable "origin_fqdns" {
  type        = list(string)
  description = "FQDN to the origin for CF distribution."
}

/* Cache Behavior */

variable "compress" {
  type        = bool
  default     = true
  description = "Compress content for web requests that include Accept-Encoding: gzip in the request header"
}

variable "default_ttl" {
  default     = 86400
  description = "Default amount of time (in seconds) that an object is in a CloudFront cache"
}

variable "min_ttl" {
  default     = 0
  description = "Minimum amount of time that you want objects to stay in CloudFront caches"
}

variable "max_ttl" {
  default     = 31536000
  description = "Maximum amount of time (in seconds) that an object is in a CloudFront cache"
}

variable "allowed_methods" {
  type        = list(string)
  default     = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  description = "List of allowed methods (e.g. GET, PUT, POST, DELETE, HEAD) for AWS CloudFront"
}

variable "cached_methods" {
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
  description = "List of cached methods (e.g. GET, PUT, POST, DELETE, HEAD)"
}
