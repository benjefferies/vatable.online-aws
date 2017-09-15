data "archive_file" "lambdaZip" {
  type = "zip"
  source_dir = "lambda/"
  output_path = "lambda.zip"
}


resource "aws_lambda_function" "createVatable2" {
  depends_on = ["data.archive_file.lambdaZip"]
  filename = "lambda.zip"
  handler = "create-vatable.createVatable2"
  function_name = "createVatable2"
  role = "${aws_iam_role.iam_for_lambda.arn}"
  source_code_hash = "${base64sha256(file("lambda.zip"))}"
  runtime = "nodejs6.10"
  timeout = 10
}

resource "aws_lambda_function" "searchVatable2" {
  depends_on = ["data.archive_file.lambdaZip"]
  filename = "${data.archive_file.lambdaZip.output_path}"
  handler = "search-vatable.searchVatable2"
  function_name = "searchVatable2"
  role = "${aws_iam_role.iam_for_lambda.arn}"
  source_code_hash = "${data.archive_file.lambdaZip.output_base64sha256}"
  runtime = "nodejs6.10"
  timeout = 10
}

resource "aws_lambda_function" "getVatable2" {
  depends_on = ["data.archive_file.lambdaZip"]
  filename = "${data.archive_file.lambdaZip.output_path}"
  handler = "get-vatable.getVatable2"
  function_name = "getVatable2"
  role = "${aws_iam_role.iam_for_lambda.arn}"
  source_code_hash = "${data.archive_file.lambdaZip.output_base64sha256}"
  runtime = "nodejs6.10"
  timeout = 10
}

resource "aws_lambda_function" "upVatable2" {
  depends_on = ["data.archive_file.lambdaZip"]
  filename = "${data.archive_file.lambdaZip.output_path}"
  handler = "up-vatable.upVatable2"
  function_name = "upVatable2"
  role = "${aws_iam_role.iam_for_lambda.arn}"
  source_code_hash = "${data.archive_file.lambdaZip.output_base64sha256}"
  runtime = "nodejs6.10"
  timeout = 10
}

resource "aws_lambda_function" "downVatable2" {
  depends_on = ["data.archive_file.lambdaZip"]
  filename = "${data.archive_file.lambdaZip.output_path}"
  handler = "down-vatable.downVatable2"
  function_name = "downVatable2"
  role = "${aws_iam_role.iam_for_lambda.arn}"
  source_code_hash = "${data.archive_file.lambdaZip.output_base64sha256}"
  runtime = "nodejs6.10"
  timeout = 10
}
