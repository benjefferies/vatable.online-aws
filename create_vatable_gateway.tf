resource "aws_api_gateway_method" "createVatableMethod" {
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.rootVatable.id}"
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_lambda_permission" "createVatableApiPermission" {
  statement_id = "createVatableApiPermission"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.createVatable2.arn}"
  principal = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account}:${aws_api_gateway_rest_api.vatableApi.id}/*/${aws_api_gateway_method.createVatableMethod.http_method}/{name}"
}

resource "aws_api_gateway_integration" "createVatableIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.rootVatable.id}"
  http_method = "${aws_api_gateway_method.createVatableMethod.http_method}"
  integration_http_method = "POST"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.createVatable2.arn}/invocations"
  passthrough_behavior = "NEVER"
  request_templates = {
    "application/json" = <<EOF
{
  "name" : "$input.params('name')"
}
EOF
  }
}

resource "aws_api_gateway_method_response" "createVatableConflict" {
  depends_on = ["aws_api_gateway_method.createVatableMethod"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.rootVatable.id}"
  http_method = "${aws_api_gateway_method.createVatableMethod.http_method}"
  status_code = "409"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "true" }
}

resource "aws_api_gateway_method_response" "createVatableOk" {
  depends_on = ["aws_api_gateway_method.createVatableMethod"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.rootVatable.id}"
  http_method = "${aws_api_gateway_method.createVatableMethod.http_method}"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "true" }
}

resource "aws_api_gateway_integration_response" "createVatableOkResponse" {
  depends_on = ["aws_api_gateway_integration.createVatableIntegration"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.rootVatable.id}"
  http_method = "${aws_api_gateway_method.createVatableMethod.http_method}"
  status_code = "${aws_api_gateway_method_response.createVatableOk.status_code}"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_integration_response" "createVatableConflictResponse" {
  depends_on = ["aws_api_gateway_integration.createVatableIntegration"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.rootVatable.id}"
  http_method = "${aws_api_gateway_method.createVatableMethod.http_method}"
  status_code = "${aws_api_gateway_method_response.createVatableConflict.status_code}"
  selection_pattern = ".*409.*"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  response_templates = {
    "application/json" = ""
  }
}