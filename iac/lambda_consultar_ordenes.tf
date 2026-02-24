resource "aws_lambda_function" "consultar_ordenes" {
  filename         = data.archive_file.placeholder.output_path
  function_name    = "${local.prefix}-consultar-ordenes"
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
      TABLE_INFORMACION_ORIGINAL = aws_dynamodb_table.informacion_original.name
      TABLE_INFORMACION_GUARDADA = aws_dynamodb_table.informacion_guardada.name
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