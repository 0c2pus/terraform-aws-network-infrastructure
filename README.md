# AWS Network Infrastructure with Terraform

[![Terraform](https://img.shields.io/badge/Terraform-v1.0+-623CE4?style=flat&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-LocalStack-FF9900?style=flat&logo=amazon-aws&logoColor=white)](https://localstack.cloud/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Infrastructure as Code implementation of production-grade AWS network architecture using Terraform and LocalStack for local development.

---

## Overview

This project demonstrates secure, scalable AWS network infrastructure following industry best practices. The infrastructure is developed and tested locally using LocalStack to eliminate cloud costs during development.

### Design Principles

- Multi-tier network architecture with public/private subnet isolation
- Modular, reusable Terraform code structure
- High availability design considerations
- Security-first approach with least privilege access
- Infrastructure state management and change tracking

## Technical Stack

- **Terraform** >= 1.0
- **AWS Provider** ~> 5.0
- **LocalStack** (AWS service emulation)
- **Docker** (LocalStack runtime)
- **Git** (version control with Git Flow)

## Current Architecture

### Network Components

**VPC:** `10.0.0.0/16`
- DNS hostnames and resolution enabled
- Isolated virtual network environment

**Public Subnet:** `10.0.1.0/24`
- Internet-facing resources
- Auto-assign public IP addresses
- Direct internet access via Internet Gateway

**Private Subnet:** `10.0.2.0/24`
- Protected backend resources
- No public IP addresses
- Outbound internet access via NAT Gateway

**Connectivity:**
- Internet Gateway for public subnet bidirectional internet access
- NAT Gateway for private subnet outbound-only internet access
- Route tables configured for proper traffic routing

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed network design documentation.

## Project Structure
```
terraform-aws-network-infrastructure/
├── ARCHITECTURE.md          # Detailed architecture documentation
├── LICENSE                  # MIT License
├── README.md               # This file
├── docker-compose.yml      # LocalStack service configuration
└── terraform/
    ├── main.tf            # Core infrastructure resources
    ├── variables.tf       # Input variable definitions
    ├── outputs.tf         # Output value definitions
    └── terraform.tfvars   # Variable values (excluded from VCS)
```

## Prerequisites

- Docker Desktop (for LocalStack)
- Terraform >= 1.0
- Git >= 2.0
- AWS CLI v2
- awslocal (AWS CLI wrapper for LocalStack)

## Setup

### Start LocalStack
```bash
docker-compose up -d
sleep 15
curl http://localhost:4566/_localstack/health
```

### Initialize and Deploy
```bash
cd terraform
terraform init
terraform validate
terraform plan
terraform apply
```

### Verify Deployment
```bash
# View outputs
terraform output

# Verify VPC
awslocal ec2 describe-vpcs

# Verify subnets
awslocal ec2 describe-subnets

# Verify route tables
awslocal ec2 describe-route-tables
```

### Destroy Infrastructure
```bash
cd terraform
terraform destroy
```

## Usage Examples

### View Network Summary
```bash
terraform output network_summary
```

### List All Created Resources
```bash
terraform state list
```

### Inspect Specific Resource
```bash
terraform state show aws_vpc.main
terraform state show aws_subnet.public
```

## Security

### Local Development

- Dummy credentials used for LocalStack
- State files excluded from version control
- Sensitive variables excluded from VCS
- Network isolation enforced through subnet design

### Production Considerations

When adapting for production AWS:

1. Remove LocalStack endpoint configuration
2. Configure IAM role-based authentication
3. Implement remote state backend (S3 + DynamoDB)
4. Enable state file encryption
5. Use AWS Secrets Manager for sensitive data
6. Deploy across multiple Availability Zones
7. Implement VPC Flow Logs for network monitoring
8. Configure Network ACLs for additional security layer

## Development Workflow

This project follows Git Flow methodology:

- `main` - production-ready code
- `develop` - integration branch
- `feature/*` - feature development branches

### Commit Convention
```
feat: new feature
fix: bug fix
docs: documentation changes
refactor: code refactoring
test: test additions
chore: maintenance tasks
```

## Project Status

### Completed

**Week 1:**
- LocalStack environment configuration
- Terraform AWS provider setup
- Project structure and Git Flow
- Professional documentation standards

**Week 2:**
- VPC creation with DNS support
- Public subnet with Internet Gateway
- Private subnet with NAT Gateway
- Route table configuration
- Network architecture documentation

### In Progress

**Week 3:**
- EC2 instance deployment
- Security Group configuration
- SSH access setup
- Bastion host implementation

### Planned

**Week 4:**
- Code modularization
- Application Load Balancer
- Final architecture diagram
- Complete documentation

## Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed network design and components
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [LocalStack Documentation](https://docs.localstack.cloud/)

## Testing

Validate infrastructure after deployment:
```bash
# Terraform validation
cd terraform
terraform validate
terraform plan

# Network connectivity tests
awslocal ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock]'
awslocal ec2 describe-subnets --query 'Subnets[*].[SubnetId,CidrBlock,MapPublicIpOnLaunch]'
awslocal ec2 describe-route-tables --query 'RouteTables[*].Routes'
```

## Cost Considerations

### Development

No costs - all resources run locally in LocalStack.

### Production Deployment

Estimated monthly AWS costs:
- VPC, Subnets, Internet Gateway: Free
- NAT Gateway: ~$32/month per AZ
- Data transfer: Variable based on usage

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

GitHub: [0c2pus](https://github.com/0c2pus)

---

**Project Status:** Active Development - Stage 2/4 Complete

Last updated: 2025-11-03
