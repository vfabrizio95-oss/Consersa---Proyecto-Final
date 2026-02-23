resource "aws_api_gateway_rest_api" "main" {
  name        = "${local.prefix}-api"
  description = "API Gateway Regional - ${local.prefix}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_authorizer" "cognito" {
  name            = "${local.prefix}-cognito-auth"
  rest_api_id     = aws_api_gateway_rest_api.main.id
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns   = [aws_cognito_user_pool.main.arn]
}