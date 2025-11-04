# AWS Network Infrastructure with Terraform

[![Terraform](https://img.shields.io/badge/Terraform-v1.0+-623CE4?style=flat&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-LocalStack-FF9900?style=flat&logo=amazon-aws&logoColor=white)](https://localstack.cloud/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Infrastructure as Code implementation of production-grade AWS network architecture using Terraform and LocalStack for local development.

## Overview

This project demonstrates secure, scalable AWS network infrastructure following industry best practices. Infrastructure is developed and tested locally using LocalStack to eliminate cloud costs during development.

### Design Principles

- Multi-tier network architecture with public/private subnet isolation
- Bastion host pattern for secure SSH access
- Principle of least privilege for security groups
- Infrastructure as Code with validation and outputs
- Git Flow methodology for version control
- Comprehensive documentation and testing procedures

## Technical Stack

- **Terraform** >= 1.0
- **AWS Provider** ~> 5.0
- **LocalStack** (AWS service emulation)
- **Docker** (LocalStack runtime)
- **Git** with Git Flow (version control)

## Current Architecture

### Network Layer

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

**Gateways:**
- Internet Gateway for public subnet bidirectional traffic
- NAT Gateway for private subnet outbound-only traffic
- Route tables configured for proper traffic routing

### Compute Layer

**Bastion Host (Public Subnet):**
- Ubuntu 22.04 LTS on t2.micro
- SSH access restricted to specific IP address
- Jump host for accessing private resources

**Application Server (Private Subnet):**
- Ubuntu 22.04 LTS on t2.micro
- SSH access only from bastion host
- Pre-installed with nginx for testing

### Security

**Security Groups:**
- Bastion: SSH from allowed IP only
- Application: SSH from bastion only, traffic from public subnet
- No direct internet SSH access to private resources

**SSH Authentication:**
- ED25519 key pair
- Key-based authentication only
- Private key stored securely locally

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed design documentation.

## Project Structure
```
terraform-aws-network-infrastructure/
├── ARCHITECTURE.md          # Detailed architecture documentation
├── TESTING.md              # Infrastructure testing procedures
├── LICENSE                 # MIT License
├── README.md              # This file
├── docker-compose.yml     # LocalStack service configuration
└── terraform/
    ├── main.tf           # Core infrastructure resources
    ├── variables.tf      # Input variable definitions
    ├── outputs.tf        # Output value definitions
    └── terraform.tfvars  # Variable values (excluded from VCS)
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

### Generate SSH Key
```bash
ssh-keygen -t ed25519 -C "terraform-aws-project" -f ~/.ssh/terraform-project/terraform-key -N ""
chmod 600 ~/.ssh/terraform-project/terraform-key
```

### Configure Terraform Variables

Create `terraform/terraform.tfvars`:
```hcl
ssh_public_key   = "ssh-ed25519 AAAA... your-public-key"
allowed_ssh_cidr = "YOUR_IP/32"
```

Get your public IP: `curl -4 ifconfig.me`

### Deploy Infrastructure
```bash
cd terraform
terraform init
terraform validate
terraform plan
terraform apply
```

## Usage

### View Infrastructure Outputs
```bash
terraform output
terraform output network_summary
terraform output compute_summary
```

### SSH Access

#### Connect to Bastion
```bash
BASTION_IP=$(terraform output -raw bastion_public_ip)
ssh -i ~/.ssh/terraform-project/terraform-key ubuntu@${BASTION_IP}
```

#### Connect to Application Server
```bash
APP_IP=$(terraform output -raw application_private_ip)
ssh -i ~/.ssh/terraform-project/terraform-key -J ubuntu@${BASTION_IP} ubuntu@${APP_IP}
```

Or use the pre-formatted command:
```bash
terraform output -raw ssh_connection_application | bash
```

### Verify Resources
```bash
awslocal ec2 describe-vpcs
awslocal ec2 describe-subnets
awslocal ec2 describe-instances
awslocal ec2 describe-security-groups
```

See [TESTING.md](TESTING.md) for comprehensive testing procedures.

### Destroy Infrastructure
```bash
terraform destroy
```

## Security

### Local Development

- Dummy AWS credentials for LocalStack
- State files excluded from version control
- Sensitive variables excluded from VCS
- SSH private keys stored locally only
- Network isolation enforced through design

### Production Considerations

For production AWS deployment:

**Authentication:**
- Remove LocalStack endpoint configuration
- Configure IAM role-based authentication
- Use AWS Secrets Manager for sensitive data

**State Management:**
- Implement remote state backend (S3 + DynamoDB)
- Enable state file encryption
- Configure state locking

**Networking:**
- Deploy across multiple Availability Zones
- Implement VPC Flow Logs
- Configure Network ACLs

**Monitoring:**
- Enable CloudWatch monitoring
- Configure CloudTrail for audit logging
- Set up SNS alerts for critical events

**SSH Access:**
- Update allowed_ssh_cidr to bastion public IP
- Consider AWS Systems Manager Session Manager
- Implement SSH certificate authority

## Development Workflow

This project follows Git Flow methodology:

- `main` - production-ready code
- `develop` - integration branch
- `feature/*` - feature development branches

### Commit Convention
```
feat: new feature implementation
fix: bug fix
docs: documentation changes
refactor: code refactoring
test: test additions
chore: maintenance tasks
```

### Branching Strategy
```bash
# Create feature branch from develop
git checkout develop
git pull origin develop
git checkout -b feature/stage-name

# Work, commit, push
git add .
git commit -m "feat: description"
git push origin feature/stage-name

# Merge via pull request
git checkout develop
git merge feature/stage-name --no-ff
git push origin develop
git branch -d feature/stage-name
```

## Project Stages

### Completed

**Stage 1: Foundation**
- LocalStack environment configuration
- Terraform AWS provider setup
- Git repository structure
- Documentation standards

**Stage 2: Network Infrastructure**
- VPC with DNS support
- Public and private subnets
- Internet Gateway and NAT Gateway
- Route table configuration
- Network architecture documentation

**Stage 3: Compute and Security**
- EC2 instances (bastion and application)
- Security Groups with least privilege
- SSH key pair management
- Bastion host implementation
- Security testing procedures

### Planned

**Stage 4: Modularization and Finalization**
- Terraform code modularization
- Reusable modules structure
- Application Load Balancer (optional)
- Architecture diagram
- Final documentation polish

## Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed infrastructure design
- [TESTING.md](TESTING.md) - Testing procedures and validation
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [LocalStack Documentation](https://docs.localstack.cloud/)

## Cost Considerations

### Development

No costs - all resources run locally in LocalStack.

### Production Deployment

Estimated monthly AWS costs:

**Network:**
- VPC, Subnets, Route Tables, Internet Gateway: Free
- NAT Gateway: ~$32/month per AZ
- Elastic IP: Free when attached

**Compute:**
- t2.micro instances: ~$8/month each
- Total for 2 instances: ~$16/month

**Estimated Total: ~$48/month**

**Optimization strategies:**
- Use t3.micro for better price/performance
- Single NAT Gateway for non-production
- Reserved Instances (up to 70% savings)
- Auto Scaling for variable workloads

## Known LocalStack Limitations

- SSH connectivity to EC2 not fully emulated
- Console output may not be available
- User data scripts may not execute fully
- AMI catalog not available (using fake AMI ID)

These limitations do not affect Terraform code quality or production AWS deployment.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

GitHub: [0c2pus](https://github.com/0c2pus)

---

**Project Status:** Active Development - Stage 3/4 Complete

Last updated: 2025-11-04