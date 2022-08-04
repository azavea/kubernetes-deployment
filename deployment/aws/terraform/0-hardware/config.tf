provider "aws" {}

terraform {
  backend "s3" {
    region = local.region
    encrypt = "true"
  }
}
