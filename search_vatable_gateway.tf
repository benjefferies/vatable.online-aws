resource "aws_api_gateway_resource" "searchVatable" {
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  parent_id = "${aws_api_gateway_rest_api.vatableApi.root_resource_id}"
  path_part = "search"
}

resource "aws_api_gateway_resource" "searchNameVatable" {
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  parent_id = "${aws_api_gateway_resource.searchVatable.id}"
  path_part = "{name}"
}

resource "aws_api_gateway_method" "searchVatableMethod" {
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.searchNameVatable.id}"
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_lambda_permission" "searchVatableApiPermission" {
  statement_id = "searchVatableApiPermission"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.searchVatable2.arn}"
  principal = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account}:${aws_api_gateway_rest_api.vatableApi.id}/*/${aws_api_gateway_method.searchVatableMethod.http_method}/search/{name}"
}

resource "aws_api_gateway_integration" "searchVatableIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.searchNameVatable.id}"
  http_method = "${aws_api_gateway_method.searchVatableMethod.http_method}"
  integration_http_method = "POST"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.searchVatable2.arn}/invocations"
  passthrough_behavior = "NEVER"
  request_templates = {
    "application/json" = <<EOF
{
  "name" : "$input.params('name')"
}
EOF
  }
}

resource "aws_api_gateway_method_response" "searchVatableOk" {
  depends_on = ["aws_api_gateway_integration.searchVatableIntegration"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.searchNameVatable.id}"
  http_method = "${aws_api_gateway_method.searchVatableMethod.http_method}"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "true" }
}

resource "aws_api_gateway_integration_response" "searchVatableOkResponse" {
  depends_on = ["aws_api_gateway_integration.searchVatableIntegration"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.searchNameVatable.id}"
  http_method = "${aws_api_gateway_method.searchVatableMethod.http_method}"
  status_code = "${aws_api_gateway_method_response.searchVatableOk.status_code}"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
}

//CORS
module "searchVatableCors" {
  source = "github.com/kevinthorley/terraform-api-gateway-cors-module"
  resource_name = "searchVatableCors"
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.searchNameVatable.id}"
}