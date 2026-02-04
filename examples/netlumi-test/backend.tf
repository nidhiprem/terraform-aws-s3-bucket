terraform {
  backend "s3" {
    bucket  = "netlumi-test-tfstate-s3module"
    key     = "s3-module-test/terraform.tfstate"
    region  = "us-east-1"
    profile = "dev-netlumi-customer"
  }
}
