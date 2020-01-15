locals {
  full_name = "${var.env}.${var.stage}"
  bucket_name = "${local.full_name}-cf-cdn"
  bucket_domain_name = "${local.bucket_name}.s3.amazonaws.com"
}

resource "aws_cloudfront_distribution" "default" {
  enabled             = true
  wait_for_deployment = true
  comment             = var.comment
  aliases             = var.aliases
  price_class         = var.price_class

  tags = {
    Name = local.full_name
  }

  dynamic "origin" {
    iterator = fqdn
    for_each = var.origin_fqdns
    content {
      domain_name = fqdn.value
      origin_id   = "ELB-${split(".", fqdn.value)[0]}"

      custom_origin_config {
        http_port  = 80
        https_port = 443

        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.cert_arn
    minimum_protocol_version       = var.minimum_protocol_version
    ssl_support_method             = "sni-only"
    cloudfront_default_certificate = false
  }

  dynamic "default_cache_behavior" {
    iterator = fqdn
    for_each = var.origin_fqdns
    content {
      target_origin_id = "ELB-${split(".", fqdn.value)[0]}"

      allowed_methods = var.allowed_methods
      cached_methods  = var.cached_methods
      compress        = var.compress

      forwarded_values {
        query_string = false
        headers      = []
        cookies { forward = "none" }
      }

      viewer_protocol_policy = "redirect-to-https"
      default_ttl            = var.default_ttl
      min_ttl                = var.min_ttl
      max_ttl                = var.max_ttl
    }
  }

  /* Special case for /metadata/all to show newly added Dapps */
  dynamic "ordered_cache_behavior" {
    iterator = fqdn
    for_each = var.origin_fqdns
    content {
      target_origin_id = "ELB-${split(".", fqdn.value)[0]}"

      path_pattern    = "/metadata/all"
      cached_methods  = ["GET", "HEAD"]
      allowed_methods = ["GET", "HEAD", "OPTIONS"]

      forwarded_values {
        query_string = false
        headers      = []
        cookies { forward = "none" }
      }

      viewer_protocol_policy = "redirect-to-https"
      min_ttl                = var.min_ttl
      default_ttl            = 60
      max_ttl                = 60
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
