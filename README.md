### Description

No description provided. Please add a data description to the module with a
description.

```tf
data "template_file" "description" {
    template = "This is my super awesome module and it does this stuff..."
}
```

### Variables

| **Name** | **Type** | **Description** | **Default** |
| -------- | ---- | ----------- | ------- |
| name | `unknown` | Name to be used on all the resources as identifier. | `""` |
| compress | `bool` | Boolean - whether or not to use gzip compression on the cloudfront distribution. | `false` |
| viewer_protocol_policy | `unknown` | Cloudfront viewer policy.
  Must be one of: allow-all, https-only, or redirect-to-https | `"redirect-to-https"` |
| ssl_cert | `unknown` | The name of the ssl cert to use from ACM. | *None* |
| domain | `unknown` | The domain to use for the site. If left out will not create a Route53 record. | `""` |
| domain_prefix | `unknown` | The domain to use for the site. If left out will not create a Route53 record. | `""` |
| extra_cnames | `list` | Any other CNAMEs you want added to the cloudfront distrobution. | `[]` |
| comment | `unknown` | A description of the CloudFront distrobution. | `""` |
| root_object | `unknown` | The root object to load when none specified. | `"index.html"` |
| tags | `map` | The tags to add to each resource that supports tags. | `{}` |
| bucket_name | `unknown` | The name for the bucket. Will default to using a $name-static-assets | `""` |
| bucket_path | `unknown` | The path in the bucket to start from. Can be left blank to start at root. | `""` |
| enable_s3_versioning | `bool` | Enable versioning on the s3 bucket or not. | `false` |
| enable_cname_dns | `bool` | Create dns records for extra_cnames. Extra_cnames must use same domain. | `false` |
| min_ttl | `integer` | Minimum TTL that can be set on an object. | `0` |
| default_ttl | `integer` | TTL of an object when one is not set. | `3600` |
| max_ttl | `integer` | Maximum TTL that can be set on an object | `86400` |
| price_class | `unknown` | The cloudfront price class to use. | `"PriceClass_100"` |
| ssl_support_method | `unknown` | The type of SLL method you want to support. | `"sni-only"` |
| minimum_protocol_version | `unknown` | minimum protocol version to require. | `"TLSv1_2016"` |
| custom_error_responses | `list` | List of custom error responses. | `[]` |

### Outputs

| **Name** | **Description** |
| -------- | --------------- |
| bucket_name | List of custom error responses. |
| bucket_arn | List of custom error responses. |
| cloudfront_id | List of custom error responses. |
| cloudfront_domain | List of custom error responses. |

### Resources used

* aws_cloudfront_origin_access_identity
* aws_cloudfront_distribution
* aws_route53_record
* aws_s3_bucket
* aws_s3_bucket_policy# terraform-cf-distribution
