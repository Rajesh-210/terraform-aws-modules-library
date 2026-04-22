output "vpc_id"             { value = module.vpc.vpc_id }
output "public_subnets"     { value = module.vpc.public_subnet_ids }
output "private_subnets"    { value = module.vpc.private_subnet_ids }
output "eks_cluster_name"   { value = module.eks.cluster_name }
output "eks_endpoint"       { value = module.eks.cluster_endpoint }
output "web_sg_id"          { value = module.security_groups.web_sg_id }
output "app_sg_id"          { value = module.security_groups.app_sg_id }
output "artifacts_bucket"   { value = module.s3_app_artifacts.bucket_name }
