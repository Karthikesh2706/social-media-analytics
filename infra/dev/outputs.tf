output "s3_bucket_name" {
  value = aws_s3_bucket.data_bucket.bucket
}

output "dashboard_name" {
  value = aws_cloudwatch_dashboard.analytics_dashboard.dashboard_name
}
