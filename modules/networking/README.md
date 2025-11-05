# Networking Module

## Description

This module creates a complete AWS network infrastructure with VPC, public and private subnets, Internet Gateway, NAT Gateway, and route tables.

## Architecture
```
VPC (configurable CIDR)
├── Public Subnet
│   ├── Internet Gateway (bidirectional internet access)
│   └── Route: 0.0.0.0/0 → IGW
└── Private Subnet
    ├── NAT Gateway (outbound-only internet access)
    └── Route: 0.0.0.0/0 → NAT
```

## Usage
```hcl
module "networking" {
  source = "./modules/networking"

  project_name         = "my-project"
  environment          = "dev"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidr   = "10.0.1.0/24"
  private_subnet_cidr  = "10.0.2.0/24"
  availability_zone    = "eu-central-1a"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Project     = "My Project"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
```

## Requirements

- Terraform >= 1.0
- AWS Provider ~> 5.0

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_name | Project name for resource naming | string | - | yes |
| environment | Environment name | string | - | yes |
| vpc_cidr | CIDR block for VPC | string | - | yes |
| public_subnet_cidr | CIDR block for public subnet | string | - | yes |
| private_subnet_cidr | CIDR block for private subnet | string | - | yes |
| availability_zone | Availability zone for subnets | string | - | yes |
| enable_dns_hostnames | Enable DNS hostnames in VPC | bool | true | no |
| enable_dns_support | Enable DNS support in VPC | bool | true | no |
| tags | Tags to apply to all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| vpc_cidr | CIDR block of the VPC |
| public_subnet_id | ID of the public subnet |
| public_subnet_cidr | CIDR block of the public subnet |
| private_subnet_id | ID of the private subnet |
| private_subnet_cidr | CIDR block of the private subnet |
| internet_gateway_id | ID of the Internet Gateway |
| nat_gateway_id | ID of the NAT Gateway |
| nat_gateway_public_ip | Public IP of the NAT Gateway |
| public_route_table_id | ID of the public route table |
| private_route_table_id | ID of the private route table |

## Resources Created

- 1 VPC
- 2 Subnets (public and private)
- 1 Internet Gateway
- 1 NAT Gateway
- 1 Elastic IP
- 2 Route Tables
- 2 Route Table Associations

Total: 10 resources

## Notes

- Public subnet enables auto-assign public IP for instances
- Private subnet has no public IP assignment
- NAT Gateway deployed in public subnet
- All resources properly tagged for management
