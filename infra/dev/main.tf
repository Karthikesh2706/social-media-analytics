resource "aws_s3_bucket" "data_bucket" {
  bucket        = "${var.project_name}-${var.environment}-data"
  force_destroy = true
}

resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "/aws/${var.project_name}/${var.environment}"
  retention_in_days = 7
}

resource "aws_cloudwatch_dashboard" "analytics_dashboard" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "text",
        x = 0,
        y = 0,
        width = 24,
        height = 3,
        properties = {
          markdown = "# 📊 Social Media Analytics Dashboard"
        }
      }
    ]
  })
}
