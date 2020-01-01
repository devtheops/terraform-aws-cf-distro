locals {
  default_tags = {
    app       = var.app
    service   = var.service
    env       = var.environment
    terraform = "true"
  }

  comment            = length(var.comment) > 0 ? var.comment : "Cloudfront distribution for ${var.name}"
  domain             = "${var.domain_prefix}${var.domain}"
  bucket_name        = length(var.bucket_name) > 0 ? var.bucket_name : local.domain
  cloudfront_aliases = compact(concat(list(local.domain), var.extra_cnames))

  custom_origin_id = length(var.custom_origins) > 0 ? lookup(element(var.custom_origins, 0), "origin_id", null) : null
  s3_origin_id     = length(var.s3_origins) > 0 ? lookup(element(var.s3_origins, 0), "origin_id", lookup(element(var.s3_origins, 0), "bucket_name", null)) : null
  default_origin   = var.custom_default_origin ? local.custom_origin_id : local.s3_origin_id

  custom_origins_have_spa = length([for behavior in var.ordered_cache_behaviors : behavior if behavior.spa_enabled == true]) > 0

  enable_spa_lambda = (var.default_spa_enabled == true || local.custom_origins_have_spa == true)
}
