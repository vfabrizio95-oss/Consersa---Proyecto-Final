resource "aws_iam_role" "lambda" {
  name = "${local.prefix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda.name
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda.name
}

resource "aws_iam_role_policy_attachment" "lambda_xray" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  role       = aws_iam_role.lambda.name
}

resource "aws_iam_role_policy" "lambda_custom" {
  name = "${local.prefix}-lambda-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Dynamo"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.usuarios.arn,
          aws_dynamodb_table.ordenes.arn,
          aws_dynamodb_table.valorizaciones.arn,
          "${aws_dynamodb_table.usuarios.arn}/index/*",
          "${aws_dynamodb_table.ordenes.arn}/index/*",
          "${aws_dynamodb_table.valorizaciones.arn}/index/*"
        ]
      },
      {
        Sid    = "S3"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = ["${aws_s3_bucket.pdfs.arn}/*"]
      },
      {
        Sid    = "SQS"
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:SendMessage"
        ]
        Resource = [
          aws_sqs_queue.valorizaciones.arn,
          aws_sqs_queue.ordenes.arn,
          aws_sqs_queue.lambda_dlq.arn
        ]
      },
      {
        Sid      = "Events"
        Effect   = "Allow"
        Action   = ["events:PutEvents"]
        Resource = [aws_cloudwatch_event_bus.main.arn]
      },
      {
        Sid    = "KMS"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = [aws_kms_key.main.arn]
      },
      {
        Sid    = "SES"
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "arn:aws:ses:${var.aws_region}:${data.aws_caller_identity.current.account_id}:identity/*"
      }
    ]
  })
}

resource "aws_signer_signing_profile" "lambda" {
  name_prefix = "consersalambda"
  platform_id = "AWSLambda-SHA384-ECDSA"
}

resource "aws_lambda_code_signing_config" "main" {
  allowed_publishers {
    signing_profile_version_arns = [
      aws_signer_signing_profile.lambda.version_arn
    ]
  }

  policies {
    untrusted_artifact_on_deployment = "Enforce"
  }
}

data "archive_file" "placeholder" {
  type        = "zip"
  output_path = "/tmp/lambda_placeholder.zip"
  source {
    filename = "index.js"
    content  = "exports.handler = async (e, c) => ({ statusCode: 200, body: JSON.stringify({ ok: true, id: c.awsRequestId }) });"
  }
}