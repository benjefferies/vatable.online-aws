resource "aws_api_gateway_rest_api" "vatableApi" {
  name = "vatableApi"
}

resource "aws_api_gateway_resource" "rootVatable" {
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  parent_id = "${aws_api_gateway_rest_api.vatableApi.root_resource_id}"
  path_part = "{name}"
}

//CORS
module "rootVatableCors" {
  source = "github.com/kevinthorley/terraform-api-gateway-cors-module"
  resource_name = "rootVatableCors"
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  resource_id = "${aws_api_gateway_resource.rootVatable.id}"
}

resource "aws_api_gateway_deployment" "vatableDeployment" {
  depends_on = ["module.rootVatableCors"]
  rest_api_id = "${aws_api_gateway_rest_api.vatableApi.id}"
  stage_name  = "prod"
}