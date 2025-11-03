# ==============================================================================
# FILE: outputs.tf
# DESCRIPTION: Output value definitions
# ==============================================================================

# ------------------------------------------------------------------------------
# LocalStack
# ------------------------------------------------------------------------------

output "localstack_endpoint" {
  description = "LocalStack API endpoint URL"
  value       = "http://localhost:4566"
}

# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

# ------------------------------------------------------------------------------
# Subnets
# ------------------------------------------------------------------------------

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "public_subnet_cidr" {
  description = "CIDR block of the public subnet"
  value       = aws_subnet.public.cidr_block
}

output "public_subnet_az" {
  description = "Availability Zone of the public subnet"
  value       = aws_subnet.public.availability_zone
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "private_subnet_cidr" {
  description = "CIDR block of the private subnet"
  value       = aws_subnet.private.cidr_block
}

output "private_subnet_az" {
  description = "Availability Zone of the private subnet"
  value       = aws_subnet.private.availability_zone
}

# ------------------------------------------------------------------------------
# Gateways
# ------------------------------------------------------------------------------

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

# ------------------------------------------------------------------------------
# Route Tables
# ------------------------------------------------------------------------------

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------

output "network_summary" {
  description = "Summary of network configuration"
  value = {
    vpc_id            = aws_vpc.main.id
    vpc_cidr          = aws_vpc.main.cidr_block
    public_subnet_id  = aws_subnet.public.id
    private_subnet_id = aws_subnet.private.id
    nat_gateway_ip    = aws_eip.nat.public_ip
    availability_zone = aws_subnet.public.availability_zone
  }
}
