# Test Auto-PR: Insecure S3 bucket with Lambda dependency
# This intentionally creates security issues to test auto-remediation

provider "aws" {
  region  = "us-east-1"
  profile = "dev-netlumi-customer"
}

locals {
  bucket_name = "netlumi-s3module-test-${formatdate("YYYYMMDDhhmmss", timestamp())}"
}

data "aws_caller_identity" "current" {}

# Use the terraform-aws-s3-bucket module with INSECURE settings
module "test_bucket" {
  source = "../../"

  bucket        = local.bucket_name
  force_destroy = true

  # Intentionally INSECURE - no encryption
  server_side_encryption_configuration = {}

  # Intentionally INSECURE - allow public access
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  tags = {
    Name        = "netlumi-s3module-test"
    Environment = "test"
    Purpose     = "auto-remediation-testing"
    ManagedBy   = "terraform"
    Repo        = "terraform-aws-s3-bucket"
  }
}

# Lambda execution role
resource "aws_iam_role" "lambda_role" {
  name = "netlumi-s3module-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "netlumi-s3module-lambda-role"
  }
}

# Policy to access the S3 bucket
resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "s3-access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]
      Resource = [
        module.test_bucket.s3_bucket_arn,
        "${module.test_bucket.s3_bucket_arn}/*"
      ]
    }]
  })
}

# Lambda function that DEPENDS on the S3 bucket
resource "aws_lambda_function" "processor" {
  filename      = "${path.module}/lambda.zip"
  function_name = "netlumi-s3module-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.11"

  environment {
    variables = {
      BUCKET_NAME = module.test_bucket.s3_bucket_id
    }
  }

  tags = {
    Name            = "netlumi-s3module-processor"
    DependsOnBucket = module.test_bucket.s3_bucket_id
  }
}

# Outputs
output "bucket_name" {
  description = "The name of the test S3 bucket"
  value       = module.test_bucket.s3_bucket_id
}

output "bucket_arn" {
  description = "The ARN of the test S3 bucket"
  value       = module.test_bucket.s3_bucket_arn
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.processor.function_name
}

output "lambda_depends_on_bucket" {
  description = "Shows Lambda dependency on S3 bucket"
  value       = "Lambda ${aws_lambda_function.processor.function_name} depends on S3 bucket ${module.test_bucket.s3_bucket_id}"
}
