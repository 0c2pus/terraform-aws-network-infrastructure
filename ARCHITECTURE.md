# Network Architecture Documentation

## Overview

This document describes the network architecture implemented in this project.

## VPC Architecture

### CIDR Allocation
```
VPC:             10.0.0.0/16    (65,536 IP addresses)
├── Public:      10.0.1.0/24    (256 IP addresses)
├── Private:     10.0.2.0/24    (256 IP addresses)
└── Reserved:    10.0.3.0/24+   (for future expansion)
```

### Subnet Design

#### Public Subnet (10.0.1.0/24)

**Purpose:** Resources that require direct internet access

**Characteristics:**
- Internet-facing resources (web servers, load balancers)
- Auto-assign public IP addresses
- Direct route to Internet Gateway
- NAT Gateway deployed here

**Route Table:**
- `10.0.0.0/16` → local (VPC internal traffic)
- `0.0.0.0/0` → Internet Gateway (all external traffic)

#### Private Subnet (10.0.2.0/24)

**Purpose:** Protected resources without direct internet exposure

**Characteristics:**
- Backend services, databases, internal applications
- No public IP addresses
- Outbound internet access via NAT Gateway
- Cannot receive inbound traffic from internet

**Route Table:**
- `10.0.0.0/16` → local (VPC internal traffic)
- `0.0.0.0/0` → NAT Gateway (outbound only)

## Network Components

### VPC (Virtual Private Cloud)

**Configuration:**
- CIDR: 10.0.0.0/16
- DNS Resolution: Enabled
- DNS Hostnames: Enabled

**Purpose:** Isolated virtual network in AWS cloud

### Internet Gateway (IGW)

**Purpose:** Enable communication between VPC and internet

**Functionality:**
- Provides target for internet-routable traffic
- Performs NAT for instances with public IP addresses
- Attached to VPC

### NAT Gateway

**Purpose:** Enable private subnet instances to access internet

**Functionality:**
- Allows outbound internet traffic from private subnet
- Blocks inbound traffic from internet
- Deployed in public subnet
- Uses Elastic IP address

**Deployment:**
- Location: Public subnet
- Availability: Single AZ (can be expanded for HA)

### Route Tables

#### Public Route Table

Associated with public subnet.

**Routes:**
- Local route (VPC CIDR) - automatic
- Default route (0.0.0.0/0) → Internet Gateway

#### Private Route Table

Associated with private subnet.

**Routes:**
- Local route (VPC CIDR) - automatic
- Default route (0.0.0.0/0) → NAT Gateway

## Traffic Flow Examples

### Public Subnet Instance to Internet
```
Instance (10.0.1.x) → Internet Gateway → Internet
```

### Internet to Public Subnet Instance
```
Internet → Internet Gateway → Instance (10.0.1.x)
```

### Private Subnet Instance to Internet
```
Instance (10.0.2.x) → NAT Gateway (10.0.1.x) → Internet Gateway → Internet
```

### Internet to Private Subnet Instance
```
Blocked - No inbound route from Internet Gateway to private subnet
```

### Public to Private Communication
```
Public Instance (10.0.1.x) → Local Route → Private Instance (10.0.2.x)
```

## Security Considerations

### Network Isolation

- Private subnet has no direct internet access
- All inbound traffic to private subnet must originate from within VPC
- Principle of least privilege applied to network design

### High Availability Considerations

Current implementation uses single Availability Zone.

**Production recommendations:**
- Deploy subnets across multiple AZs
- Use multiple NAT Gateways (one per AZ)
- Implement cross-AZ load balancing

### Scalability

**Current capacity:**
- Public subnet: 251 usable IPs (256 - 5 AWS reserved)
- Private subnet: 251 usable IPs

**Expansion options:**
- Additional subnets: 10.0.3.0/24, 10.0.4.0/24, etc.
- VPC supports up to 256 subnets
- Can be expanded to multi-AZ without CIDR changes

## Resource Tagging Strategy

All resources tagged with:
- `Project`: Project identifier
- `Environment`: dev/staging/prod
- `ManagedBy`: Terraform
- `Name`: Human-readable resource name
- `Type`: Resource type where applicable

## Cost Optimization Notes

### LocalStack Development

No AWS costs during development - all resources run locally.

### Production Deployment Costs

Estimated monthly costs (AWS):
- VPC: Free
- Subnets: Free
- Internet Gateway: Free
- NAT Gateway: ~$32/month (per AZ)
- Elastic IP: Free (when attached to running instance)
- Data transfer: Variable

**Cost optimization recommendations:**
- Use single NAT Gateway for non-production
- Consider NAT Instances for very low traffic
- Monitor data transfer costs

## Maintenance and Operations

### State Management

- Terraform state stored locally (development)
- Production should use remote state (S3 + DynamoDB)

### Updates and Changes

All infrastructure changes managed through:
1. Feature branch creation
2. Terraform plan review
3. Pull request process
4. Merge to develop
5. Deploy to production (from main)

## Testing Checklist

Verify after deployment:
- [ ] VPC created with correct CIDR
- [ ] Both subnets created in correct AZ
- [ ] Internet Gateway attached to VPC
- [ ] NAT Gateway in public subnet with Elastic IP
- [ ] Route tables configured correctly
- [ ] Route table associations correct
- [ ] All resources properly tagged

## References

- AWS VPC Documentation: https://docs.aws.amazon.com/vpc/
- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/
- Network CIDR Calculator: https://www.subnet-calculator.com/

---

Last updated: 2025-11-03
