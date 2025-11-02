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
- High availability across multiple Availability Zones
- Security-first approach with least privilege access
- Infrastructure state management and change tracking

---

## Technical Stack

- **Terraform** >= 1.0
- **AWS Provider** ~> 5.0
- **LocalStack** (AWS service emulation)
- **Docker** (LocalStack runtime)
- **Git** (version control)

---

## Project Structure
```
terraform-aws-project/
├── docker-compose.yml       # LocalStack service configuration
├── terraform/
│   ├── main.tf             # Provider and core configuration
│   ├── variables.tf        # Input variable definitions
│   ├── outputs.tf          # Output value definitions
│   └── terraform.tfvars    # Variable values (excluded from VCS)
├── .gitignore              # VCS exclusions
└── README.md               # Project documentation
```

---

## Prerequisites

- Docker Desktop
- Terraform >= 1.0
- Git >= 2.0
- AWS CLI v2

---

## Setup

### Start LocalStack
```bash
docker-compose up -d
sleep 15
curl http://localhost:4566/_localstack/health
```

### Initialize Terraform
```bash
cd terraform
terraform init
terraform validate
terraform plan
```

---

## Usage

### Deploy Infrastructure
```bash
cd terraform
terraform plan
terraform apply
```

### Verify Deployment
```bash
awslocal ec2 describe-vpcs
awslocal ec2 describe-subnets
```

### Destroy Infrastructure
```bash
cd terraform
terraform destroy
```

---

## Security

### Local Development

- Dummy credentials used for LocalStack
- State files excluded from version control
- Sensitive variables excluded from version control

### Production Considerations

For production AWS deployment:

- Remove LocalStack endpoint configuration
- Configure IAM role-based authentication
- Implement remote state backend with encryption
- Enable state locking with DynamoDB
- Store secrets in AWS Secrets Manager
- Enable CloudTrail for audit logging

---

## Development Workflow

This project follows Git Flow:

- `main` - production-ready code
- `develop` - integration branch
- `feature/*` - feature development branches

### Commit Convention
```
feat: add new feature
fix: bug fix
docs: documentation changes
refactor: code refactoring
test: test additions or modifications
```

---

## Current Status

### Completed

- LocalStack environment configuration
- Terraform AWS provider setup
- Project structure and documentation

### In Progress

- VPC and subnet configuration
- Internet Gateway and NAT Gateway
- Route table configuration

### Planned

- EC2 instance provisioning
- Security Group configuration
- Application Load Balancer
- Code modularization

## License

MIT [LICENSE](LICENSE)

## Author

0c2pus  
- GitHub: [0c2pus](https://github.com/0c2pus)

---

Last updated: 2025-11-02
