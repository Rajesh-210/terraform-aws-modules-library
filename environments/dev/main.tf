##############################################################
# ENVIRONMENT: DEV
# Wires all modules together for the dev environment.
##############################################################

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = local.common_tags
  }
}

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {
    bucket         = "rajesh-terraform-state-dev"
    key            = "aws-modules/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "Rajesh-DevOps"
  }
}

# ── VPC ───────────────────────────────────────────────────
module "vpc" {
  source       = "../../modules/vpc"
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  availability_zones   = ["ap-south-1a", "ap-south-1b"]
  enable_nat_gateway   = true
  tags                 = local.common_tags
}

# ── Security Groups ───────────────────────────────────────
module "security_groups" {
  source       = "../../modules/security-groups"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  app_port     = 5000
  db_port      = 5432
  tags         = local.common_tags
}

# ── IAM Roles ─────────────────────────────────────────────
module "iam" {
  source           = "../../modules/iam"
  project_name     = var.project_name
  environment      = var.environment
  create_ec2_role  = true
  create_cicd_role = true
  tags             = local.common_tags
}

# ── S3 Buckets ────────────────────────────────────────────
module "s3_app_artifacts" {
  source        = "../../modules/s3"
  project_name  = var.project_name
  environment   = var.environment
  bucket_suffix = "app-artifacts"
  tags          = local.common_tags
}

module "s3_logs" {
  source        = "../../modules/s3"
  project_name  = var.project_name
  environment   = var.environment
  bucket_suffix = "logs"
  tags          = local.common_tags
}

# ── EKS Cluster ───────────────────────────────────────────
module "eks" {
  source          = "../../modules/eks"
  cluster_name    = "${var.project_name}-${var.environment}"
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  instance_types  = ["t3.medium"]
  desired_nodes   = 2
  min_nodes       = 1
  max_nodes       = 5
  tags            = local.common_tags
}
