# S3 bucket for data storage
resource "aws_s3_bucket" "data_bucket" {
  bucket        = "${var.project_name}-${var.environment}-data"
  force_destroy = true
}

# CloudWatch log group for app logs
resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "/aws/${var.project_name}/${var.environment}"
  retention_in_days = 7
}

# CloudWatch dashboard for analytics
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

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnet
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# Generate random suffix
resource "random_id" "grafana_suffix" {
  byte_length = 4
}

# Security group for Grafana
resource "aws_security_group" "grafana_sg" {
  name        = "${var.project_name}-${var.environment}-grafana-sg"
  description = "Allow Grafana (port 3000) and SSH (port 22)"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana web access"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance for Grafana
resource "aws_instance" "grafana_server" {
  ami           = "ami-0c55b159cbfafe1f0" # Ubuntu 22.04 for us-east-1
  instance_type = "t2.micro"
  subnet_id = tolist(data.aws_subnets.default.ids)[0]

  vpc_security_group_ids = [aws_security_group.grafana_sg.id]

  tags = {
    Name = "${var.project_name}-${var.environment}-grafana"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              docker run -d -p 3000:3000 grafana/grafana
              EOF
}
