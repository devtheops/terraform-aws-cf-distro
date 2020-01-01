resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  count = length(var.s3_origins) > 0 ? 1 : 0

  comment = "Origin access identity for ${var.name}"
}

data "aws_iam_policy_document" "s3_policy" {
  count = length(var.s3_origins)

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${lookup(element(var.s3_origins, count.index), "bucket_arn", "")}/*"]

    principals {
      type        = "AWS"
      identifiers = aws_cloudfront_origin_access_identity.origin_access_identity.*.iam_arn
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [lookup(element(var.s3_origins, count.index), "bucket_arn", "")]

    principals {
      type        = "AWS"
      identifiers = aws_cloudfront_origin_access_identity.origin_access_identity.*.iam_arn
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  count = length(var.s3_origins)

  bucket = lookup(element(var.s3_origins, count.index), "bucket_name", "")
  policy = element(data.aws_iam_policy_document.s3_policy.*.json, count.index)
}
