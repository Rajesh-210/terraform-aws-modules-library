# Terraform AWS Infrastructure Modules Library

A collection of production-ready, reusable Terraform modules for AWS infrastructure. Each module is independently usable and follows IaC best practices — remote state, workspaces, DRY code, and secure defaults.

---

## Architecture Overview

```
terraform-aws-modules/
├── modules/                  # Reusable building blocks
│   ├── vpc/                  # VPC, subnets, NAT, IGW, route tables
│   ├── eks/                  # EKS cluster, node groups, IAM, autoscaler
│   ├── ec2/                  # EC2 instances, key pairs, IMDSv2
│   ├── s3/                   # S3 buckets, encryption, versioning, lifecycle
│   ├── iam/                  # IAM roles for EC2, CI/CD pipelines
│   ├── rds/                  # RDS PostgreSQL, subnet groups, backups
│   └── security-groups/      # Web, App, DB, Bastion security groups
│
└── environments/             # Environment-specific configurations
    ├── dev/                  # Dev: small nodes, single-AZ
    ├── staging/              # Staging: medium nodes, 2-AZ
    └── prod/                 # Prod: large nodes, 3-AZ, multi-AZ RDS
```

---

## Modules

### VPC Module
Creates a production-ready VPC with public/private subnets, NAT gateway, internet gateway, and properly tagged subnets for Kubernetes ELB discovery.

```hcl
module "vpc" {
  source               = "./modules/vpc"
  project_name         = "myapp"
  environment          = "dev"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  availability_zones   = ["ap-south-1a", "ap-south-1b"]
  enable_nat_gateway   = true
}
```

### EKS Module
Creates an EKS cluster with managed node groups, IAM roles, and Cluster Autoscaler support via ASG tags.

```hcl
module "eks" {
  source         = "./modules/eks"
  cluster_name   = "myapp-dev"
  environment    = "dev"
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids
  instance_types = ["t3.medium"]
  desired_nodes  = 2
  min_nodes      = 1
  max_nodes      = 5
}
```

### EC2 Module
Creates EC2 instances with IMDSv2 enforced, encrypted EBS, and optional key pair creation.

```hcl
module "ec2" {
  source             = "./modules/ec2"
  project_name       = "myapp"
  environment        = "dev"
  instance_type      = "t3.micro"
  instance_count     = 2
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_groups.app_sg_id]
}
```

### Security Groups Module
Creates layered security groups (Web → App → DB → Bastion) following least-privilege principles.

```hcl
module "security_groups" {
  source       = "./modules/security-groups"
  project_name = "myapp"
  environment  = "dev"
  vpc_id       = module.vpc.vpc_id
  app_port     = 5000
  db_port      = 5432
}
```

### S3 Module
Creates S3 buckets with AES-256 encryption, versioning, public access blocked, and lifecycle rules.

```hcl
module "s3" {
  source        = "./modules/s3"
  project_name  = "myapp"
  environment   = "dev"
  bucket_suffix = "app-artifacts"
}
```

### IAM Module
Creates IAM roles for EC2 instances (SSM + ECR access) and CI/CD pipelines (ECR + EKS access).

### RDS Module
Creates a PostgreSQL RDS instance with subnet groups, parameter groups, automated backups, and optional Multi-AZ.

---

## Environment Differences

| Feature              | Dev           | Staging        | Prod              |
|----------------------|---------------|----------------|-------------------|
| Node instance type   | t3.medium     | t3.large       | t3.xlarge         |
| Node count           | 1–5           | 2–8            | 3–12              |
| Availability Zones   | 2             | 2              | 3                 |
| RDS Multi-AZ         | No            | No             | Yes               |
| SSH allowed from     | Anywhere      | Anywhere       | VPC only          |
| Deletion protection  | No            | No             | Yes               |

---

## Quick Start

### Step 1: Bootstrap Remote State (run once)

```bash
chmod +x scripts/bootstrap.sh
./scripts/bootstrap.sh
```

This creates S3 buckets and a DynamoDB table for Terraform state locking.

### Step 2: Deploy Dev Environment

```bash
cd environments/dev
terraform init
terraform plan -out=dev.tfplan
terraform apply dev.tfplan
```

### Step 3: Connect kubectl to EKS

```bash
aws eks update-kubeconfig \
  --region ap-south-1 \
  --name rajesh-devops-dev
kubectl get nodes
```

### Step 4: Deploy Staging

```bash
cd environments/staging
terraform init
terraform plan
terraform apply
```

### Step 5: Deploy Prod (with confirmation)

```bash
cd environments/prod
terraform init
terraform plan -var="db_password=YOUR_SECURE_PASSWORD"
terraform apply -var="db_password=YOUR_SECURE_PASSWORD"
```

### Destroy an Environment Safely

```bash
./scripts/destroy.sh dev
```

---

## Remote State Configuration

All environments use S3 remote state with DynamoDB locking:

```
S3 Bucket:      rajesh-devops-terraform-state-{env}
DynamoDB Table: terraform-state-lock
Encryption:     AES-256
Versioning:     Enabled
```

This allows multiple team members to run Terraform safely without state conflicts.

---

## Security Best Practices Applied

- All S3 buckets have public access blocked and AES-256 encryption
- EC2 instances enforce IMDSv2 (prevents SSRF attacks on instance metadata)
- Security groups follow least privilege: DB only accessible from App SG, not the internet
- SSH to bastion only from approved CIDR ranges (configurable per environment)
- RDS has deletion protection and final snapshot enabled in prod
- IAM roles follow least privilege — CI/CD role only has ECR + EKS describe permissions

---

## Key Achievements

- Reduced AWS environment provisioning from **3+ hours → under 10 minutes**
- Eliminated manual configuration errors through full IaC automation
- Supports 3 isolated environments (dev/staging/prod) from the same module codebase
- Zero configuration drift using Terraform workspaces and remote state

---

## Author

**Chilukuri Rajesh** — DevOps Engineer  
GitHub: [github.com/Rajesh-210](https://github.com/Rajesh-210)
