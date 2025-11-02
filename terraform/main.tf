# ============================================
# Terraform Configuration for LocalStack
# ============================================
# Project: AWS Network Infrastructure (LocalStack)
# Author: 0c2pus
# Date: 2025-11-02

# Terraform settings
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ============================================
# AWS Provider Configuration for LocalStack
# ============================================
provider "aws" {
  # Region (simulation)
  region = var.aws_region

  # Fake credentials for LocalStack
  # LocalStack not check true credentials
  access_key = "test"
  secret_key = "test"

  # CRITICAL: Turn on AWS check
  # LocalStack - its a local simulation, not true AWS
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # Endpoints - all requests run by LocalStack
  endpoints {
    ec2                    = "http://localhost:4566"
    iam                    = "http://localhost:4566"
    s3                     = "http://localhost:4566"
    sts                    = "http://localhost:4566"
    elasticloadbalancing   = "http://localhost:4566"
    elasticloadbalancingv2 = "http://localhost:4566"
  }
}

# ============================================
# Data Sources
# ============================================
# Recive information about available Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# ============================================
# Outputs for check in connection
# ============================================
output "localstack_endpoint" {
  description = "LocalStack API endpoint"
  value       = "http://localhost:4566"
}

output "aws_region" {
  description = "AWS Region (simulated in LocalStack)"
  value       = var.aws_region
}

output "availability_zones" {
  description = "Available Availability Zones"
  value       = data.aws_availability_zones.available.names
}
