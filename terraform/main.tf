# ==============================================================================
# FILE: main.tf
# DESCRIPTION: Main Terraform configuration
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

provider "aws" {
  region = var.aws_region

  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2                    = "http://localhost:4566"
    iam                    = "http://localhost:4566"
    s3                     = "http://localhost:4566"
    sts                    = "http://localhost:4566"
    elasticloadbalancing   = "http://localhost:4566"
    elasticloadbalancingv2 = "http://localhost:4566"
  }
}

# ==============================================================================
# DATA SOURCES
# ==============================================================================

data "aws_availability_zones" "available" {
  state = "available"
}

# ==============================================================================
# VPC
# ==============================================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-vpc"
    }
  )
}

# ==============================================================================
# SUBNETS
# ==============================================================================

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[var.availability_zone_index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-public-subnet"
      Type = "Public"
    }
  )
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[var.availability_zone_index]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-subnet"
      Type = "Private"
    }
  )
}

# ==============================================================================
# INTERNET GATEWAY
# ==============================================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-igw"
    }
  )
}

# ==============================================================================
# ELASTIC IP FOR NAT GATEWAY
# ==============================================================================

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-nat-eip"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# ==============================================================================
# NAT GATEWAY
# ==============================================================================

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-nat-gw"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# ==============================================================================
# ROUTE TABLES
# ==============================================================================

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-public-rt"
      Type = "Public"
    }
  )
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-rt"
      Type = "Private"
    }
  )
}

# ==============================================================================
# ROUTE TABLE ASSOCIATIONS
# ==============================================================================

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
