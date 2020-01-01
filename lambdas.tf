resource "aws_iam_role_policy" "spa_policy" {
  count       = local.enable_spa_lambda ? 1 : 0
  name_prefix = "${var.app}-spa"
  role        = join("", aws_iam_role.spa_role.*.id)

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogGroup"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "spa_role" {
  count              = local.enable_spa_lambda ? 1 : 0
  name_prefix        = "${var.app}-spa"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "edgelambda.amazonaws.com",
          "lambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(local.default_tags, var.tags)
}



data "archive_file" "default_spa_zip" {
  count = local.enable_spa_lambda ? 1 : 0
  type  = "zip"

  source {
    content = templatefile("${path.module}/spa_lambda.js", {
      INDEX_PATH = var.default_spa_index
    })
    filename = "spa_lambda.js"
  }

  output_path = "${path.module}/files/default_spa_lambda.zip"
}

resource "aws_lambda_function" "default_spa_lambda" {
  count            = local.enable_spa_lambda ? 1 : 0
  filename         = join("", data.archive_file.default_spa_zip.*.output_path)
  function_name    = "marctest-spa-test"
  role             = join("", aws_iam_role.spa_role.*.arn)
  handler          = "spa_lambda.handler"
  source_code_hash = join("", data.archive_file.default_spa_zip.*.output_base64sha256)
  runtime          = "nodejs8.10"
  tags             = merge(local.default_tags, var.tags)
  publish          = true
}
