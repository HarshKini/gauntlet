# Auto-proposal: enforce S3 block public access
# Review & edit before apply.
resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.app.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
