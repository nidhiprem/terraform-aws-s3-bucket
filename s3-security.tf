resource "aws_s3_bucket_public_access_block" "netlumi_s3module_test" {
  bucket = "netlumi-s3module-test-20260210224908"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}