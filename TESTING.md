# Infrastructure Testing Guide

## Overview

This document describes how to test the deployed infrastructure.

## Prerequisites

- LocalStack running
- Terraform applied successfully
- awslocal CLI configured

## Network Testing

### VPC Verification
```bash
awslocal ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock]'
```

**Expected:** VPC with CIDR 10.0.0.0/16

### Subnet Verification
```bash
awslocal ec2 describe-subnets --query 'Subnets[*].[SubnetId,CidrBlock,MapPublicIpOnLaunch]'
```

**Expected:**
- Public subnet: 10.0.1.0/24, MapPublicIpOnLaunch: true
- Private subnet: 10.0.2.0/24, MapPublicIpOnLaunch: false

### Route Table Verification
```bash
# Public routes
awslocal ec2 describe-route-tables --filters "Name=tag:Type,Values=Public" --query 'RouteTables[0].Routes'
```

**Expected routes:**
- 10.0.0.0/16 → local
- 0.0.0.0/0 → Internet Gateway
```bash
# Private routes
awslocal ec2 describe-route-tables --filters "Name=tag:Type,Values=Private" --query 'RouteTables[0].Routes'
```

**Expected routes:**
- 10.0.0.0/16 → local
- 0.0.0.0/0 → NAT Gateway

## Security Testing

### Security Group Rules Verification
```bash
# Bastion security group
awslocal ec2 describe-security-groups --filters "Name=group-name,Values=*bastion-sg" --query 'SecurityGroups[0].IpPermissions'
```

**Expected ingress:**
- Port 22 (SSH) from your IP only
```bash
# Application security group
awslocal ec2 describe-security-groups --filters "Name=group-name,Values=*app-sg" --query 'SecurityGroups[0].IpPermissions'
```

**Expected ingress:**
- Port 22 (SSH) from bastion security group only
- All traffic from public subnet (10.0.1.0/24)

### Key Pair Verification
```bash
awslocal ec2 describe-key-pairs
```

**Expected:** Key pair with name matching project

## Compute Testing

### EC2 Instance Verification
```bash
awslocal ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,PrivateIpAddress]'
```

**Expected:**
- 2 instances in "running" state
- Bastion: has both public and private IP
- Application: has only private IP

### Instance Connectivity

#### Bastion Host
```bash
BASTION_IP=$(cd terraform && terraform output -raw bastion_public_ip)
ssh -i ~/.ssh/terraform-project/terraform-key ubuntu@${BASTION_IP} "hostname; date"
```

**Note:** SSH connectivity may not work in LocalStack but will work in real AWS.

#### Application Server (via Bastion)
```bash
APP_IP=$(cd terraform && terraform output -raw application_private_ip)
ssh -i ~/.ssh/terraform-project/terraform-key -J ubuntu@${BASTION_IP} ubuntu@${APP_IP} "hostname; date"
```

## Resource Tagging

### Verify All Resources Have Required Tags
```bash
awslocal ec2 describe-tags --filters "Name=resource-type,Values=vpc,subnet,instance,security-group" --query 'Tags[*].[ResourceId,Key,Value]' --output table
```

**Expected tags on all resources:**
- Project
- Environment
- ManagedBy: Terraform
- Stage: 3

## Terraform State Verification

### List All Resources
```bash
cd terraform
terraform state list
```

**Expected resources:**
- 1 VPC
- 2 Subnets
- 1 Internet Gateway
- 1 NAT Gateway
- 1 Elastic IP
- 2 Route Tables
- 2 Route Table Associations
- 2 Security Groups
- 1 Key Pair
- 2 EC2 Instances

Total: 15 resources

### Resource Dependencies
```bash
terraform state show aws_instance.application | grep vpc_security_group_ids
terraform state show aws_instance.application | grep subnet_id
```

**Verify:**
- Application instance uses application security group
- Application instance in private subnet

## Outputs Verification
```bash
terraform output
```

**Verify all outputs are populated:**
- VPC ID and CIDR
- Subnet IDs and CIDRs
- Gateway IDs
- Route Table IDs
- Security Group IDs
- Instance IDs and IPs
- SSH connection commands

## Cleanup Testing

### Destroy Infrastructure
```bash
terraform destroy -auto-approve
```

**Verify:**
- All resources deleted
- No orphaned resources remain

### Recreate Infrastructure
```bash
terraform apply -auto-approve
```

**Verify:**
- All resources recreate successfully
- IDs change but configuration remains consistent
- Outputs show new resource IDs

## Known LocalStack Limitations

1. **SSH Connectivity:** LocalStack does not fully emulate SSH access to EC2 instances
2. **Console Output:** Instance console output may not be available
3. **User Data Execution:** User data scripts may not execute
4. **AMI Catalog:** Real AWS AMI IDs not available, using fake AMI ID

These limitations do not affect Terraform code quality or AWS production deployment.

## Production Deployment Differences

When deploying to real AWS:

1. Replace fake AMI ID with real Ubuntu AMI data source
2. Update SSH allowed CIDR to production bastion IP
3. Configure remote state backend (S3 + DynamoDB)
4. Enable VPC Flow Logs
5. Add CloudWatch monitoring
6. Configure IAM roles instead of dummy credentials

---

Last updated: 2025-11-04
