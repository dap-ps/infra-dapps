variable "bucket_name" {
  description = "Name of the S3 bucket."
  type        = string
}

variable "description" {
  description = "Description explaining purpose of bucket."
  type        = string
  default     = "S3 Bucket created by Terraform"
}
