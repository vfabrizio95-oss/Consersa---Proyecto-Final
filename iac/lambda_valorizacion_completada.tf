resource "aws_lambda_function" "valorizacion_completada" {
  filename         = data.archive_file.placeholder.output_path
  function_name    = "${local.prefix}-valorizacion-completada"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 60
  memory_size      = 512
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
      SNS_VALORIZACION           = aws_sns_topic.valorizacion_terminada.arn
      SES_FROM_EMAIL             = "notificaciones@${var.domain_name}"
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_valorizacion" {
  event_source_arn        = aws_sqs_queue.valorizaciones.arn
  function_name           = aws_lambda_function.valorizacion_completada.arn
  batch_size              = 10
  function_response_types = ["ReportBatchItemFailures"]
}
