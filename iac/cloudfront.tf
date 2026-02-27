resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "${local.prefix} frontend"
  price_class         = "PriceClass_100"
  web_acl_id = aws_wafv2_web_acl.api.arn

  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.frontend.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.frontend.id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["PE"]
    }
  }

  viewer_certificate {
  acm_certificate_arn      = aws_acm_certificate.cert.arn
  ssl_support_method       = "sni-only"
  minimum_protocol_version = "TLSv1.2_2021"
}

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs.bucket_domain_name
    prefix          = "cloudfront/"
}

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${local.prefix}-cloudfront-logs"
}

resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "${local.prefix}-frontend-oac"
  description                       = "OAC para S3 frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "${local.prefix}-security-headers"

  security_headers_config {
    content_type_options {
      override = true
      }
    frame_options {
      frame_option = "DENY"
      override = true
      }
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override = true
      }
    xss_protection {
      protection = true
      mode_block = true
      override = true
      }

    strict_transport_security {
      access_control_max_age_sec = 63072000
      include_subdomains = true
      preload = true
      override = true
    }
  }
}