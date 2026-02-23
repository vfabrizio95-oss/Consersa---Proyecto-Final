resource "aws_cloudwatch_event_bus" "main" {
  name = "${local.prefix}-bus"
  tags = {
    Name = "${local.prefix}-event-bus"
  }
}

resource "aws_cloudwatch_event_rule" "orden_recibida" {
  name           = "${local.prefix}-orden-recibida"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["Concersa.ordenes"]
    detail-type = ["Order recibida"]
  })
}

resource "aws_cloudwatch_event_bus_policy" "allow_account" {
  event_bus_name = aws_cloudwatch_event_bus.main.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowAccountPutEvents"
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
      Action    = "events:PutEvents"
      Resource  = aws_cloudwatch_event_bus.main.arn
    }]
  })
}