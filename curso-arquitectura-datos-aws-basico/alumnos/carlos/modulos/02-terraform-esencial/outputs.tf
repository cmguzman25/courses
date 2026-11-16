output "buckets" {

  description = "Bucket name per zone"
  value       = { for zone, b in aws_s3_bucket.zone : zone => b.bucket }

}