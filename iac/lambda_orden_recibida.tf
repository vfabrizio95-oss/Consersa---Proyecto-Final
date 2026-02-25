resource "aws_lambda_function" "orden_recibida" {
  filename         = data.archive_file.placeholder.output_path
  function_name    = "${local.prefix}-orden-recibida"
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
    }
  }
}

resource "aws_lambda_permission" "api_gateway_orden_recibida" {
  statement_id  = "AllowAPIGW"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.orden_recibida.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}//"
}