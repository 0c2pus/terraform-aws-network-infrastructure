# ==============================================================================
# FILE: main.tf
# DESCRIPTION: Main Terraform configuration for AWS infrastructure with LocalStack
# AUTHOR: 0c2pus
# DATE: 2025-11-02
# VERSION: 1.0.0
# ==============================================================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ==============================================================================
# PROVIDER CONFIGURATION
# ==============================================================================
# Configure AWS provider to use LocalStack for local development.
# In production, remove endpoints block and configure proper AWS credentials.

provider "aws" {
  region = var.aws_region

  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2                     = "http://localhost:4566"
    iam                     = "http://localhost:4566"
    s3                      = "http://localhost:4566"
    sts                     = "http://localhost:4566"
    elasticloadbalancing    = "http://localhost:4566"
    elasticloadbalancingv2  = "http://localhost:4566"
  }
}

# ==============================================================================
# DATA SOURCES
# ==============================================================================

data "aws_availability_zones" "available" {
  state = "available"
}

# ==============================================================================
# OUTPUTS
# ==============================================================================

output "localstack_endpoint" {
  description = "LocalStack API endpoint URL"
  value       = "http://localhost:4566"
}

output "aws_region" {
  description = "AWS region used for resource deployment"
  value       = var.aws_region
}

output "availability_zones" {
  description = "List of available Availability Zones"
  value       = data.aws_availability_zones.available.names
}
