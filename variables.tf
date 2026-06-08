variable "aws_region" {
  description = "AWS region to deploy infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "jaramarket"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "microservices" {
  description = "List of microservices"
  type        = list(string)
  default     = ["cart", "catalog", "orders"]
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "jaramarket"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for ALB and CloudFront"
  type        = string
}

variable "artifact_bucket_name" {
  description = "S3 bucket for CodePipeline artifacts"
  type        = string
}

variable "repository_id" {
  description = "GitHub repository ID for CodePipeline"
  type        = string
}

variable "codestar_connection_arn" {
  description = "CodeStar connection ARN for GitHub integration"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "IAM Role ARN for CodePipeline"
  type        = string
}

variable "codebuild_role_arn" {
  description = "IAM Role ARN for CodeBuild"
  type        = string
}

variable "codedeploy_role_arn" {
  description = "IAM Role ARN for CodeDeploy"
  type        = string
}
