output "cluster_name"            { value = aws_eks_cluster.main.name }
output "cluster_endpoint"        { value = aws_eks_cluster.main.endpoint }
output "cluster_ca_data"         { value = aws_eks_cluster.main.certificate_authority[0].data }
output "cluster_version"         { value = aws_eks_cluster.main.version }
output "node_group_role_arn"     { value = aws_iam_role.node_group.arn }
output "cluster_security_group"  { value = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id }
