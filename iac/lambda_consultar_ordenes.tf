resource "aws_lambda_function" "consultar_ordenes" {
  filename         = data.archive_file.placeholder.output_path
  function_name    = "${local.prefix}-consultar-ordenes"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 30
  memory_size      = 256
  source_code_hash = data.archive_file.placeholder.output_base64sha256
  
  kms_key_arn = aws_kms_key.main.arn
  reserved_concurrent_executions = 10
  code_signing_config_arn = aws_lambda_code_signing_config.main.arn

  dead_letter_config {
    target_arn = aws_sqs_queue.ordenes_dlq.arn
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
      TABLE_USUARIOS       = aws_dynamodb_table.usuarios.name
      TABLE_ORDENES        = aws_dynamodb_table.ordenes.name
      TABLE_VALORIZACIONES = aws_dynamodb_table.valorizaciones.name
    }
  }
}

resource "aws_lambda_permission" "api_gateway_consultar" {
  statement_id  = "AllowAPIGW"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.consultar_ordenes.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}//"
}