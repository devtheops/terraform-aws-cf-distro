provider "aws" {
  # us-east-1 instance
  region = "us-east-1"
  alias  = "us-east-1"
}

terraform {
  required_version = ">= 0.12.2"
}

data "aws_acm_certificate" "cert" {
  domain      = var.ssl_cert
  provider    = aws.us-east-1
  statuses    = ["ISSUED"]
  most_recent = true
}

resource "aws_cloudfront_distribution" "distribution" {
  depends_on = [
    data.aws_acm_certificate.cert,
    aws_cloudfront_origin_access_identity.origin_access_identity
  ]

  enabled             = true
  is_ipv6_enabled     = true
  comment             = local.comment
  default_root_object = var.root_object
  aliases             = local.cloudfront_aliases
  price_class         = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # S3 optional origin
  dynamic "origin" {
    for_each = var.s3_origins

    content {
      domain_name = origin.value.bucket_domain_name
      origin_path = lookup(origin.value, "origin_path", null)
      origin_id   = lookup(origin.value, "origin_id", origin.value.bucket_name)

      s3_origin_config {
        origin_access_identity = join("", aws_cloudfront_origin_access_identity.origin_access_identity.*.cloudfront_access_identity_path)
      }
    }
  }

  # Custom origins passed to the module
  dynamic "origin" {
    for_each = var.custom_origins

    content {
      domain_name = origin.value.domain_name
      origin_path = origin.value.origin_path
      origin_id   = origin.value.origin_id

      dynamic "custom_header" {
        for_each = origin.value.custom_headers

        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }

      custom_origin_config {
        http_port                = origin.value.custom_origin_config.http_port
        https_port               = origin.value.custom_origin_config.https_port
        origin_protocol_policy   = origin.value.custom_origin_config.origin_protocol_policy
        origin_ssl_protocols     = origin.value.custom_origin_config.origin_ssl_protocols
        origin_keepalive_timeout = origin.value.custom_origin_config.origin_keepalive_timeout
        origin_read_timeout      = origin.value.custom_origin_config.origin_read_timeout
      }
    }
  }

  default_cache_behavior {
    allowed_methods  = var.default_allowed_methods
    cached_methods   = var.default_cached_methods
    target_origin_id = local.default_origin

    dynamic "forwarded_values" {
      for_each = list(var.default_cache_behavior_forwarded_values)

      content {
        cookies {
          forward           = forwarded_values.value.cookies.forward
          whitelisted_names = forwarded_values.value.cookies.whitelisted_names
        }

        headers                 = forwarded_values.value.headers
        query_string            = forwarded_values.value.query_string
        query_string_cache_keys = forwarded_values.value.query_string_cache_keys
      }
    }

    dynamic "lambda_function_association" {
      for_each = var.default_spa_enabled ? [1] : []
      content {
        event_type   = "origin-request"
        lambda_arn   = "${join("", aws_lambda_function.default_spa_lambda.*.arn)}:${join("", aws_lambda_function.default_spa_lambda.*.version)}"
        include_body = false
      }
    }


    viewer_protocol_policy = var.viewer_protocol_policy
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
    compress               = var.compress
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors

    content {
      path_pattern     = ordered_cache_behavior.value.path_pattern
      allowed_methods  = ordered_cache_behavior.value.allowed_methods
      cached_methods   = ordered_cache_behavior.value.cached_methods
      target_origin_id = ordered_cache_behavior.value.target_origin_id

      dynamic "forwarded_values" {
        for_each = list(ordered_cache_behavior.value.forwarded_values)

        content {
          cookies {
            forward           = forwarded_values.value.cookies.forward
            whitelisted_names = forwarded_values.value.cookies.whitelisted_names
          }

          headers                 = forwarded_values.value.headers
          query_string            = forwarded_values.value.query_string
          query_string_cache_keys = forwarded_values.value.query_string_cache_keys
        }
      }

      dynamic "lambda_function_association" {
        for_each = lookup(ordered_cache_behavior.value, "spa_enabled", false) ? [1] : []
        content {
          event_type   = "origin-request"
          lambda_arn   = "${join("", aws_lambda_function.default_spa_lambda.*.arn)}:${join("", aws_lambda_function.default_spa_lambda.*.version)}"
          include_body = false
        }
      }

      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy
      min_ttl                = ordered_cache_behavior.value.min_ttl
      default_ttl            = ordered_cache_behavior.value.default_ttl
      max_ttl                = ordered_cache_behavior.value.max_ttl
      compress               = ordered_cache_behavior.value.compress
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses

    content {
      error_code            = custom_error_response.value.error_code
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
    }
  }

  tags = merge(local.default_tags, var.tags)

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.cert.arn
    ssl_support_method       = var.ssl_support_method
    minimum_protocol_version = var.minimum_protocol_version
  }

  web_acl_id = var.web_acl_id
}

data "aws_route53_zone" "zone" {
  count        = length(var.domain) > 0 ? 1 : 0
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "record" {
  count = length(var.domain) == 0 || var.enable_cname_dns ? 0 : 1

  zone_id = data.aws_route53_zone.zone[0].zone_id
  name    = local.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "alias_record" {
  count = length(var.domain) > 0 && var.enable_cname_dns ? length(local.cloudfront_aliases) : 0

  zone_id = data.aws_route53_zone.zone[0].zone_id
  name    = element(local.cloudfront_aliases, count.index)
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
