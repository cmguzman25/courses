# First S3 bucket
resource "aws_s3_bucket" "first" {
  bucket = "my-first-data-bucket"
}

# Challenge: second bucket
resource "aws_s3_bucket" "second" {
  bucket = "my-second-data-bucket"
}

output "bucket_name" {
  value = aws_s3_bucket.first.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.first.arn
}

output "second_bucket_arn" {
  value = aws_s3_bucket.second.arn
}
