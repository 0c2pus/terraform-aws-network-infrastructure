## Compute Resources

### EC2 Instances

#### Bastion Host

**Purpose:** Secure entry point for SSH access to private resources

**Configuration:**
- Location: Public subnet (10.0.1.0/24)
- Instance Type: t2.micro
- Operating System: Ubuntu 22.04 LTS
- Public IP: Auto-assigned
- Private IP: Dynamic within subnet range

**Security:**
- Security Group allows SSH (port 22) only from specified IP address
- Acts as jump host for accessing private subnet resources
- SSH key authentication required

**Use Cases:**
- SSH access to private subnet instances
- Administrative tasks requiring secure shell access
- Monitoring and troubleshooting

#### Application Server

**Purpose:** Backend application hosting in isolated environment

**Configuration:**
- Location: Private subnet (10.0.2.0/24)
- Instance Type: t2.micro
- Operating System: Ubuntu 22.04 LTS
- Public IP: None
- Private IP: Dynamic within subnet range

**Security:**
- No direct internet access for inbound traffic
- SSH access only from bastion host
- Outbound internet access via NAT Gateway

**Pre-installed Software:**
- nginx (web server for testing)
- Standard system utilities (htop, curl, wget, net-tools)

### Security Groups

Security Groups function as virtual firewalls controlling inbound and outbound traffic.

#### Bastion Security Group

**Inbound Rules (Ingress):**
```
Protocol: TCP
Port: 22 (SSH)
Source: Specified IP address/CIDR only
Description: SSH access from trusted location
```

**Outbound Rules (Egress):**
```
Protocol: All
Port: All
Destination: 0.0.0.0/0
Description: Allow all outbound traffic
```

**Design Rationale:**
- Restricts SSH access to known IP addresses
- Prevents unauthorized access attempts
- Allows bastion to reach any destination for administrative tasks

#### Application Security Group

**Inbound Rules (Ingress):**
```
1. Protocol: TCP
   Port: 22 (SSH)
   Source: Bastion Security Group
   Description: SSH access from bastion only

2. Protocol: All
   Port: All
   Source: 10.0.1.0/24 (Public subnet)
   Description: Application traffic from public subnet
```

**Outbound Rules (Egress):**
```
Protocol: All
Port: All
Destination: 0.0.0.0/0
Description: Allow all outbound traffic
```

**Design Rationale:**
- No direct internet SSH access
- Only bastion can initiate SSH connections
- Public subnet can reach application (for load balancer or API gateway)
- Application can reach external services via NAT Gateway

### SSH Key Management

**Key Pair Configuration:**
- Algorithm: ED25519 (modern, secure)
- Storage: `~/.ssh/terraform-project/terraform-key`
- Permissions: 600 (read/write owner only)
- Public key registered in AWS Key Pairs

**Usage:**
```bash
# Connect to bastion
ssh -i ~/.ssh/terraform-project/terraform-key ubuntu@<bastion-public-ip>

# Connect to application via bastion (ProxyJump)
ssh -i ~/.ssh/terraform-project/terraform-key -J ubuntu@<bastion-public-ip> ubuntu@<app-private-ip>
```

## Security Patterns

### Bastion Host Pattern

**Implementation:**
```
Internet → Bastion (Public Subnet) → Application (Private Subnet)
```

**Benefits:**
- Single point of entry for SSH access
- Centralized access control and logging
- Private resources remain isolated from internet
- Easier to monitor and audit access

**Best Practices Applied:**
- Restrict bastion SSH access by source IP
- Use SSH keys instead of passwords
- Implement jump host configuration with ProxyJump
- Keep bastion minimal (no application workloads)

### Network Segmentation

**Public Subnet (DMZ):**
- Internet-facing resources only
- Bastion host
- Future: Load balancers, API gateways

**Private Subnet (Secure Zone):**
- Application servers
- Databases (future)
- Internal services
- No direct internet exposure

### Least Privilege Access

**Principles:**
- Application server: No inbound internet access
- Bastion: SSH only, no application services
- Security Groups: Minimum required ports only
- Source restrictions: Specific IPs/Security Groups only

## Traffic Flow Examples (Updated)

### SSH to Bastion
```
Admin (Allowed IP) → Internet → Internet Gateway → Bastion (Public Subnet)
```

Security: Bastion Security Group checks source IP

### SSH to Application Server
```
Admin → Bastion (ProxyJump) → Application (Private Subnet)
```

Security:
1. Bastion Security Group allows admin's IP
2. Application Security Group allows bastion's Security Group

### Application Outbound Traffic
```
Application (Private Subnet) → NAT Gateway (Public Subnet) → Internet Gateway → Internet
```

Use Cases:
- Software updates (apt update)
- External API calls
- Database connections to external services

### Application Inbound from Public Resources
```
Public Subnet Resource → Application Security Group → Application (Private Subnet)
```

Use Cases:
- Load balancer health checks
- API Gateway requests
- Future public-facing services

## Updated Resource Summary

### Network Layer (Stage 2)
- 1 VPC (10.0.0.0/16)
- 2 Subnets (public/private)
- 1 Internet Gateway
- 1 NAT Gateway
- 1 Elastic IP
- 2 Route Tables
- 2 Route Table Associations

### Compute and Security Layer (Stage 3)
- 2 EC2 Instances (bastion/application)
- 2 Security Groups
- 1 SSH Key Pair

**Total Managed Resources:** 15

## Cost Optimization Notes (Updated)

### LocalStack Development

No costs - all resources run locally.

### Production AWS Deployment

**Monthly estimates:**

Network:
- VPC, Subnets, Route Tables: Free
- Internet Gateway: Free
- NAT Gateway: ~$32/month per AZ
- Elastic IP: Free (when attached)

Compute:
- t2.micro instances: ~$8/month each (~$16 for both)
- Data transfer: Variable

**Total estimated: ~$48/month**

**Optimization strategies:**
- Use t3.micro for better performance/price ratio
- Single NAT Gateway for dev/staging
- Reserved Instances for production (up to 70% savings)
- Auto Scaling for variable workloads
- Spot Instances for non-critical workloads

## Testing Checklist (Updated)

Infrastructure validation:

Network:
- [ ] VPC created with correct CIDR
- [ ] Subnets in correct AZs
- [ ] Internet Gateway attached
- [ ] NAT Gateway operational
- [ ] Route tables configured correctly

Compute:
- [ ] EC2 instances running
- [ ] Bastion has public IP
- [ ] Application has only private IP
- [ ] SSH key pair registered

Security:
- [ ] Security Groups created
- [ ] Bastion SG allows SSH from allowed IP only
- [ ] Application SG allows SSH from bastion only
- [ ] No security group allows 0.0.0.0/0 SSH access

Connectivity:
- [ ] SSH to bastion successful
- [ ] SSH to application via bastion successful
- [ ] Application can reach internet (via NAT)
- [ ] Application cannot be reached from internet directly

---

Last updated: 2025-11-04 (Stage 3 complete)