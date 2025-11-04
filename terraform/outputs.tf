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

# ------------------------------------------------------------------------------
# Security Groups
# ------------------------------------------------------------------------------

output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = aws_security_group.bastion.id
}

output "application_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.application.id
}

# ------------------------------------------------------------------------------
# EC2 Instances
# ------------------------------------------------------------------------------

output "bastion_instance_id" {
  description = "ID of the bastion instance"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion instance"
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP of the bastion instance"
  value       = aws_instance.bastion.private_ip
}

output "application_instance_id" {
  description = "ID of the application instance"
  value       = aws_instance.application.id
}

output "application_private_ip" {
  description = "Private IP of the application instance"
  value       = aws_instance.application.private_ip
}

# ------------------------------------------------------------------------------
# SSH Connection Information
# ------------------------------------------------------------------------------

output "ssh_connection_bastion" {
  description = "SSH command to connect to bastion host"
  value       = "ssh -i ~/.ssh/terraform-project/terraform-key ubuntu@${aws_instance.bastion.public_ip}"
}

output "ssh_connection_application" {
  description = "SSH command to connect to application server via bastion"
  value       = "ssh -i ~/.ssh/terraform-project/terraform-key -J ubuntu@${aws_instance.bastion.public_ip} ubuntu@${aws_instance.application.private_ip}"
}

# ------------------------------------------------------------------------------
# Compute Summary
# ------------------------------------------------------------------------------

output "compute_summary" {
  description = "Summary of compute resources"
  value = {
    bastion_public_ip      = aws_instance.bastion.public_ip
    bastion_private_ip     = aws_instance.bastion.private_ip
    application_private_ip = aws_instance.application.private_ip
    key_pair_name          = aws_key_pair.main.key_name
    ami_id                 = local.ami_id
  }
}
