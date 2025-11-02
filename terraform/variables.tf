# ============================================
# Variables Definition
# ============================================

variable "aws_region" {
  description = "AWS Region for LocalStack simulation"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "terraform-localstack-network"
}

variable "environment" {
  description = "Environment (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "Network Infrastructure"
    ManagedBy   = "Terraform"
    Environment = "Development"
  }
}
