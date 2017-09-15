//GET
resource "aws_api_gateway_method" "getVatableMethod" {
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.rootVatable.id}"
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_lambda_permission" "getVatableApiPermission" {
  statement_id = "getVatableApiPermission"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.getVatable2.arn}"
  principal = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account}:${aws_api_gateway_rest_api.vatableApi.id}/*/${aws_api_gateway_method.getVatableMethod.http_method}/{name}"
}

resource "aws_api_gateway_integration" "getVatableIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.rootVatable.id}"
  http_method = "${aws_api_gateway_method.getVatableMethod.http_method}"
  integration_http_method = "POST"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.getVatable2.arn}/invocations"
  passthrough_behavior = "NEVER"
  request_templates = {
    "application/json" = <<EOF
{
  "name" : "$input.params('name')"
}
EOF
  }
}

resource "aws_api_gateway_method_response" "getVatableNotFound" {
  depends_on = ["aws_api_gateway_method.getVatableMethod"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.rootVatable.id}"
  http_method = "${aws_api_gateway_method.getVatableMethod.http_method}"
  status_code = "404"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "true" }
}

resource "aws_api_gateway_method_response" "getVatableOk" {
  depends_on = ["aws_api_gateway_method.getVatableMethod"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.rootVatable.id}"
  http_method = "${aws_api_gateway_method.getVatableMethod.http_method}"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "true" }
}

resource "aws_api_gateway_integration_response" "getVatableOkResponse" {
  depends_on = ["aws_api_gateway_integration.getVatableIntegration"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.rootVatable.id}"
  http_method = "${aws_api_gateway_method.getVatableMethod.http_method}"
  status_code = "${aws_api_gateway_method_response.getVatableOk.status_code}"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_integration_response" "getVatableNotFoundResponse" {
  depends_on = ["aws_api_gateway_integration.getVatableIntegration"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.rootVatable.id}"
  http_method = "${aws_api_gateway_method.getVatableMethod.http_method}"
  status_code = "${aws_api_gateway_method_response.getVatableNotFound.status_code}"
  selection_pattern = ".*404.*"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  response_templates = {
    "application/json" = ""
  }
}