terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "dev-netlumi-customer"
}

# Create an S3 bucket with NO encryption (security issue)
module "test_bucket_no_encryption" {
  source = "../../"

  bucket = "netlumi-test-bucket-s3module-${substr(uuid(), 0, 8)}"

  # Intentionally skip encryption configuration to trigger detection
  server_side_encryption_configuration = {}

  # Add tags for identification
  tags = {
    Name        = "netlumi-test-s3-module"
    Purpose     = "auto-pr-testing"
    HasIssue    = "no-encryption"
  }
}

output "bucket_id" {
  value = module.test_bucket_no_encryption.s3_bucket_id
}

output "bucket_arn" {
  value = module.test_bucket_no_encryption.s3_bucket_arn
}
