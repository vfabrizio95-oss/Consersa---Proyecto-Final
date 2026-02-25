resource "aws_lambda_function" "valorizacion_consersa" {
  filename         = data.archive_file.placeholder.output_path
  function_name    = "${local.prefix}-valorizacion-consersa"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 30
  memory_size      = 256
  source_code_hash = data.archive_file.placeholder.output_base64sha256

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      TABLE_USUARIOS             = aws_dynamodb_table.usuarios.name
      TABLE_ORDENES        = aws_dynamodb_table.ordenes.name       
      TABLE_VALORIZACIONES = aws_dynamodb_table.valorizaciones.name
      EVENT_BUS_NAME             = aws_cloudwatch_event_bus.main.name
      SQS_VAL_URL                = aws_sqs_queue.valorizaciones.url
    }
  }
}

resource "aws_lambda_permission" "api_gateway_valorizacion" {
  statement_id  = "AllowAPIGW"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.valorizacion_consersa.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}