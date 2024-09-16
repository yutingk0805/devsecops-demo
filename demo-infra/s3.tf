resource "aws_s3_bucket" "bucket" {
  bucket = "devsecops-demo-bucket-18092024"
  # Deliberately vulnerable (no server-side encryption)
  # High Severity: Vulnerable (unencrypted S3)

}

# Secure configuration (commeneted out):
resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

# Bucket logging explicitly defined (Low severity control, even though it's default behavior)
# resource "aws_s3_bucket" "log_bucket" {
#   bucket = "devsecops-demo-logging-bucket-18092024"
# }

# resource "aws_s3_bucket_logging" "bucket_logging" {
#   bucket        = aws_s3_bucket.bucket.id
#   target_bucket = aws_s3_bucket.log_bucket.id
#   target_prefix = "logs/"
# }
