resource "aws_lambda_function" "pdf_processing" {
  filename         = data.archive_file.placeholder.output_path
  function_name    = "${local.prefix}-pdf-processing"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 120
  memory_size      = 1024
  source_code_hash = data.archive_file.placeholder.output_base64sha256

  kms_key_arn                    = aws_kms_key.main.arn

  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq.arn
  }

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      PDF_BUCKET           = aws_s3_bucket.pdfs.bucket
      TABLE_ORDENES        = aws_dynamodb_table.ordenes.name
      TABLE_VALORIZACIONES = aws_dynamodb_table.valorizaciones.name
    }
  }

  ephemeral_storage {
    size = 1024
  }
}
