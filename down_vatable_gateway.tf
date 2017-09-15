resource "aws_api_gateway_resource" "downVatable" {
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  parent_id = "${aws_api_gateway_rest_api.vatableApi.root_resource_id}"
  path_part = "down"
}

resource "aws_api_gateway_resource" "downNameVatable" {
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  parent_id = "${aws_api_gateway_resource.downVatable.id}"
  path_part = "{name}"
}

resource "aws_api_gateway_method" "downVatableMethod" {
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.downNameVatable.id}"
  http_method = "PUT"
  authorization = "NONE"
}

resource "aws_lambda_permission" "downVatableApiPermission" {
  statement_id = "downVatableApiPermission"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.downVatable2.arn}"
  principal = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account}:${aws_api_gateway_rest_api.vatableApi.id}/*/${aws_api_gateway_method.downVatableMethod.http_method}/down/{name}"
}

resource "aws_api_gateway_integration" "downVatableIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.downNameVatable.id}"
  http_method = "${aws_api_gateway_method.downVatableMethod.http_method}"
  integration_http_method = "POST"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.downVatable2.arn}/invocations"
  passthrough_behavior = "NEVER"
  request_templates = {
    "application/json" = <<EOF
{
  "name" : "$input.params('name')"
}
EOF
  }
}

resource "aws_api_gateway_method_response" "downVatableNotFound" {
  depends_on = ["aws_api_gateway_method.downVatableMethod"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.downNameVatable.id}"
  http_method = "${aws_api_gateway_method.downVatableMethod.http_method}"
  status_code = "404"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "true" }
}

resource "aws_api_gateway_method_response" "downVatableOk" {
  depends_on = ["aws_api_gateway_method.downVatableMethod"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.downNameVatable.id}"
  http_method = "${aws_api_gateway_method.downVatableMethod.http_method}"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "true" }
}

resource "aws_api_gateway_integration_response" "downVatableOkResponse" {
  depends_on = ["aws_api_gateway_integration.downVatableIntegration"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.downNameVatable.id}"
  http_method = "${aws_api_gateway_method.downVatableMethod.http_method}"
  status_code = "${aws_api_gateway_method_response.downVatableOk.status_code}"
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_integration_response" "downVatableNotFoundResponse" {
  depends_on = ["aws_api_gateway_integration.downVatableIntegration"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.downNameVatable.id}"
  http_method = "${aws_api_gateway_method.downVatableMethod.http_method}"
  status_code = "${aws_api_gateway_method_response.downVatableNotFound.status_code}"
  selection_pattern = ".*404.*"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  response_templates = {
    "application/json" = ""
  }
}

//CORS
module "downVatableCors" {
  source = "github.com/kevinthorley/terraform-api-gateway-cors-module"
  resource_name = "downVatableCors"
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.downNameVatable.id}"
}