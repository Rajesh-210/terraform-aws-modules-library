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
    bucket         = "rajesh-terraform-state-prod"
    key            = "aws-modules/prod/terraform.tfstate"
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
    CostCenter  = "production"
  }
}

module "vpc" {
  source               = "../../modules/vpc"
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = "10.2.0.0/16"
  public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
  private_subnet_cidrs = ["10.2.10.0/24", "10.2.11.0/24", "10.2.12.0/24"]
  availability_zones   = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  enable_nat_gateway   = true
  tags                 = local.common_tags
}

module "security_groups" {
  source            = "../../modules/security-groups"
  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  allowed_ssh_cidrs = ["10.2.0.0/16"] # Restrict SSH to VPC only in prod
  tags              = local.common_tags
}

module "iam" {
  source       = "../../modules/iam"
  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags
}

module "s3_app_artifacts" {
  source        = "../../modules/s3"
  project_name  = var.project_name
  environment   = var.environment
  bucket_suffix = "app-artifacts"
  tags          = local.common_tags
}

module "eks" {
  source         = "../../modules/eks"
  cluster_name   = "${var.project_name}-${var.environment}"
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids
  instance_types = ["t3.xlarge"]
  desired_nodes  = 4
  min_nodes      = 3
  max_nodes      = 12
  tags           = local.common_tags
}

module "rds" {
  source             = "../../modules/rds"
  project_name       = var.project_name
  environment        = var.environment
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_groups.database_sg_id]
  db_name            = "appdb"
  db_username        = "dbadmin"
  db_password        = var.db_password
  instance_class     = "db.t3.medium"
  multi_az           = true
  deletion_protection = true
  tags               = local.common_tags
}
