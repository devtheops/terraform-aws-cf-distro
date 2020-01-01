variable "app" {
  description = "The name of the application"
}

variable "service" {
  description = "The service within the application"
}

variable "environment" {
  description = "The tag environment"
  default     = "development"
}

variable "name" {
  description = "Name to be used on all the resources as identifier."
}

variable "compress" {
  description = "Boolean - whether or not to use gzip compression on the cloudfront distribution."
  default     = false
}

variable "viewer_protocol_policy" {
  description = <<EOF
  Cloudfront viewer policy.
  Must be one of: allow-all, https-only, or redirect-to-https
  
EOF


  default = "redirect-to-https"
}

variable "ssl_cert" {
  description = "The name of the ssl cert to use from ACM."
}

variable "domain" {
  description = "The domain to use for the site. If left out will not create a Route53 record."
  default     = ""
}

variable "domain_prefix" {
  description = "The domain to use for the site. If left out will not create a Route53 record."
  default     = ""
}

variable "extra_cnames" {
  description = "Any other CNAMEs you want added to the cloudfront distrobution."
  default     = []
}

variable "comment" {
  description = "A description of the CloudFront distrobution."
  default     = ""
}

variable "root_object" {
  description = "The root object to load when none specified."
  default     = "index.html"
}

variable "tags" {
  description = "The tags to add to each resource that supports tags."
  default     = {}
}

variable "bucket_name" {
  description = "The name for the bucket. Will default to using a $name-static-assets"
  default     = ""
}

variable "bucket_path" {
  description = "The path in the bucket to start from. Can be left blank to start at root."
  default     = ""
}

variable "enable_s3_versioning" {
  description = "Enable versioning on the s3 bucket or not."
  default     = false
}

variable "enable_cname_dns" {
  description = "Create dns records for extra_cnames. Extra_cnames must use same domain."
  default     = false
}

variable "min_ttl" {
  description = "Minimum TTL that can be set on an object."
  default     = 0
}

variable "default_ttl" {
  description = "TTL of an object when one is not set."
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum TTL that can be set on an object"
  default     = 86400
}

variable "price_class" {
  description = "The cloudfront price class to use."
  default     = "PriceClass_100"
}

variable "ssl_support_method" {
  description = "The type of SLL method you want to support."
  default     = "sni-only"
}

variable "minimum_protocol_version" {
  description = "minimum protocol version to require."
  default     = "TLSv1_2016"
}

variable "custom_origins" {
  description = <<EOF
  Optional list of custom origins.
  Expected structure:

  type    = list(object({
    domain_name = string
    origin_path = string
    origin_id = string

    custom_headers = list(object({
      name  = string
      value = string
    }))

    custom_origin_config = object({
      http_port                = number
      https_port               = number
      origin_protocol_policy   = string
      origin_ssl_protocols     = list(string)
      origin_keepalive_timeout = number, null
      origin_read_timeout      = number, null
    })
  }))
EOF
  default     = []
  type = list(object({
    domain_name = string
    origin_path = string
    origin_id   = string

    custom_headers = list(object({
      name  = string
      value = string
    }))

    custom_origin_config = object({
      http_port                = number
      https_port               = number
      origin_protocol_policy   = string
      origin_ssl_protocols     = list(string)
      origin_keepalive_timeout = number
      origin_read_timeout      = number
    })
  }))
}

variable "custom_error_responses" {
  description = <<EOF
  Optional list of custom error responses.
  Expected structure:

  type = list(object({
    error_code            = string
    * error_caching_min_ttl = string, null
    * response_code         = string, null
    * response_page_path    = string, null
  }))
EOF
  default     = []
  type = list(object({
    error_code            = number
    error_caching_min_ttl = number
    response_code         = number
    response_page_path    = string
  }))
}

variable "web_acl_id" {
  description = "The web ACL ID, enables WAF"
  default     = ""
}

variable "custom_default_origin" {
  description = "The default origin type. Can be 'S3' (false) or 'Custom' (true), will use the first element in the s3 or custom origins variable."
  type        = bool
  default     = false
}

variable "default_cache_behavior_forwarded_values" {
  description = "Forwarded values for the default cache behavior"

  type = object({
    cookies = object({
      forward           = string
      whitelisted_names = list(string)
    })
    headers                 = list(string)
    query_string            = bool
    query_string_cache_keys = list(string)
  })

  default = {
    cookies = {
      forward           = "none"
      whitelisted_names = null
    }

    headers                 = null
    query_string            = false
    query_string_cache_keys = null
  }
}

variable "ordered_cache_behaviors" {
  description = <<EOF
  Additional cache behaviors
  Expected structure:

  list(object({
    path_pattern     = string
    allowed_methods  = list(string)
    cached_methods   = list(string)
    target_origin_id = string

    spa_enabled      = bool
    spa_index        = string

    forwarded_values = object({
      cookies                 = object({
        forward           = string
        whitelisted_names = list(string)
      })
      headers                 = list(string)
      query_string            = bool
      query_string_cache_keys = list(string)
    })

    viewer_protocol_policy = string
    min_ttl                = number
    default_ttl            = number
    max_ttl                = number
    compress               = bool
  }))
EOF

  default = []

  type = list(object({
    path_pattern     = string
    allowed_methods  = list(string)
    cached_methods   = list(string)
    target_origin_id = string

    spa_enabled = bool
    spa_index   = string

    forwarded_values = object({
      cookies = object({
        forward           = string
        whitelisted_names = list(string)
      })
      headers                 = list(string)
      query_string            = bool
      query_string_cache_keys = list(string)
    })

    viewer_protocol_policy = string
    min_ttl                = number
    default_ttl            = number
    max_ttl                = number
    compress               = bool
  }))
}

variable "s3_origins" {
  description = <<EOF
    S3 bucket origins
    Expected structure:

    list(object({
      bucket_domain_name = string
      bucket_arn = string
      origin_path = string (optional)
      origin_id = string (optional)
      bucket_name = string
  }))
EOF

  default = []

  type = list(object({
    bucket_domain_name = string
    bucket_arn         = string
    bucket_name        = string
  }))
}

variable "default_allowed_methods" {
  description = "Allowed methods for default cache behavior"
  default     = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
}

variable "default_cached_methods" {
  description = "Cached methods for default cache behavior"
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "default_spa_enabled" {
  description = "Enables lambda@edge that rewrites origin-requests that do not have file extentions to {default_spa_index}"
  default     = false
}

variable "default_spa_index" {
  description = "Sets the default page to redirect to in a SPA when lambda@edge is enabled."
  default     = "/index.html"
}