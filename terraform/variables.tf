variable "aws_region" {
  description = "AWS region where resources will be provisioned"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "devops-assignment"
}

variable "app_port" {
  description = "Port on which the application runs inside the container"
  type        = number
  default     = 8000
}

variable "desired_count" {
  description = "Desired number of ECS Fargate tasks to run"
  type        = number
  default     = 2
}

variable "ecr_repository" {
  description = "Name of the ECR repository for the application image"
  type        = string
  default     = "devops-assignment-app"
}

variable "alert_email" {
  description = "Email address to send CloudWatch alarms to"
  type        = string
  # IMPORTANT: Change this to your actual email address before applying Terraform
  default     = "your-email@example.com"
}

variable "db_credentials" {
  description = "JSON string of database credentials to store in Secrets Manager"
  type        = string
  default     = <<EOF
{
  "username": "admin",
  "password": "your_secure_password"
}
EOF
  sensitive = true
} 