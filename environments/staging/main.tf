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
    bucket         = "rajesh-terraform-state-staging"
    key            = "aws-modules/staging/terraform.tfstate"
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

module "vpc" {
  source               = "../../modules/vpc"
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = "10.1.0.0/16"
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24"]
  availability_zones   = ["ap-south-1a", "ap-south-1b"]
  enable_nat_gateway   = true
  tags                 = local.common_tags
}

module "security_groups" {
  source       = "../../modules/security-groups"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  tags         = local.common_tags
}

module "iam" {
  source       = "../../modules/iam"
  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags
}

module "eks" {
  source         = "../../modules/eks"
  cluster_name   = "${var.project_name}-${var.environment}"
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids
  instance_types = ["t3.large"]
  desired_nodes  = 3
  min_nodes      = 2
  max_nodes      = 8
  tags           = local.common_tags
}
