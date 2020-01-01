provider "aws" {
  region = "us-east-1"
}

module "cloudfront-distribution" {
  source            = "../."

  app                   = "test"
  service               = "backend"
  environment           = "test"
  ssl_cert              = "internal.knowbe4.com"
  name                  = "test"
  custom_default_origin = true

  custom_origins = [{
    domain_name    = "https://training.knowbe4.com"
    origin_path    = null
    origin_id      = "api"
    custom_headers = []

    custom_origin_config = {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1"]
      origin_keepalive_timeout = null
      origin_read_timeout      = null
    }
  }]
}


module "cloudfront-distribution-with-spa" {
  source            = "../."

  app                   = "test"
  service               = "backend"
  environment           = "test"
  ssl_cert              = "internal.knowbe4.com"
  name                  = "test"
  custom_default_origin = true
  default_spa_enabled   = true

  custom_origins = [{
    domain_name    = "https://training.knowbe4.com"
    origin_path    = null
    origin_id      = "api"
    custom_headers = []

    custom_origin_config = {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1"]
      origin_keepalive_timeout = null
      origin_read_timeout      = null
    }
  }]
}
