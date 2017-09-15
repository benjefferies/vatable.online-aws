resource "aws_api_gateway_resource" "upVatable" {
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  parent_id = "${aws_api_gateway_rest_api.vatableApi.root_resource_id}"
  path_part = "up"
}

resource "aws_api_gateway_resource" "upNameVatable" {
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  parent_id = "${aws_api_gateway_resource.upVatable.id}"
  path_part = "{name}"
}

resource "aws_api_gateway_method" "upVatableMethod" {
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.upNameVatable.id}"
  http_method = "PUT"
  authorization = "NONE"
}

resource "aws_lambda_permission" "upVatableApiPermission" {
  statement_id = "upVatableApiPermission"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.upVatable2.arn}"
  principal = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account}:${aws_api_gateway_rest_api.vatableApi.id}/*/${aws_api_gateway_method.upVatableMethod.http_method}/up/{name}"
}

resource "aws_api_gateway_integration" "upVatableIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.upNameVatable.id}"
  http_method = "${aws_api_gateway_method.upVatableMethod.http_method}"
  integration_http_method = "POST"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.upVatable2.arn}/invocations"
  passthrough_behavior = "NEVER"
  request_templates = {
    "application/json" = <<EOF
{
  "name" : "$input.params('name')"
}
EOF
  }
}

resource "aws_api_gateway_method_response" "upVatableNotFound" {
  depends_on = ["aws_api_gateway_method.upVatableMethod"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.upNameVatable.id}"
  http_method = "${aws_api_gateway_method.upVatableMethod.http_method}"
  status_code = "404"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "true" }
}

resource "aws_api_gateway_method_response" "upVatableOk" {
  depends_on = ["aws_api_gateway_method.upVatableMethod"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.upNameVatable.id}"
  http_method = "${aws_api_gateway_method.upVatableMethod.http_method}"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "true" }
}

resource "aws_api_gateway_integration_response" "upVatableOkResponse" {
  depends_on = ["aws_api_gateway_integration.upVatableIntegration"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.upNameVatable.id}"
  http_method = "${aws_api_gateway_method.upVatableMethod.http_method}"
  status_code = "${aws_api_gateway_method_response.upVatableOk.status_code}"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_integration_response" "upVatableNotFoundResponse" {
  depends_on = ["aws_api_gateway_integration.upVatableIntegration"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.upNameVatable.id}"
  http_method = "${aws_api_gateway_method.upVatableMethod.http_method}"
  status_code = "${aws_api_gateway_method_response.upVatableNotFound.status_code}"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  response_templates = {
    "application/json" = ""
  }
  selection_pattern = ".*404.*"
}

//CORS
module "upVatableCors" {
  source = "github.com/kevinthorley/terraform-api-gateway-cors-module"
  resource_name = "upVatableCors"
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.upNameVatable.id}"
}