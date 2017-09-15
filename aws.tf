provider "aws" {
  access_key = "ACCESS_KEY"
  secret_key = "SECRET_KEY"
  region     = "eu-west-2"
}

variable "region" {
  type = "string"
  default = "eu-west-2"
}

variable "account" {
  type = "string"
  default = "ACCOUNT_ID"
}
