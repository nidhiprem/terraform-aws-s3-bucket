terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
  }

  backend "s3" {
    bucket = "customer-terraform-state-dev"
    key    = "terraform-aws-s3-bucket/test-auto-pr.tfstate"
    region = "us-east-1"
    profile = "dev-netlumi-customer"
  }
}
