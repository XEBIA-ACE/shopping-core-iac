# ─────────────────────────────────────────────
# VPC
# ─────────────────────────────────────────────
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "IDs of the private app subnets (EKS nodes)"
  value       = aws_subnet.private_app[*].id
}

output "private_data_subnet_ids" {
  description = "IDs of the private data subnets (RDS, Redis)"
  value       = aws_subnet.private_data[*].id
}

# ─────────────────────────────────────────────
# EKS Cluster
# ─────────────────────────────────────────────
output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS cluster API server endpoint"
  value       = aws_eks_cluster.main.endpoint
  sensitive   = true
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data for the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = aws_eks_cluster.main.version
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for the EKS cluster (used for IRSA)"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  value       = aws_iam_openid_connect_provider.eks.arn
}

# ─────────────────────────────────────────────
# Node Groups
# ─────────────────────────────────────────────
output "node_group_arns" {
  description = "ARNs of the EKS managed node groups"
  value       = { for k, v in aws_eks_node_group.main : k => v.arn }
}

output "node_group_role_arn" {
  description = "IAM role ARN for EKS worker nodes"
  value       = aws_iam_role.eks_node_group.arn
}

# ─────────────────────────────────────────────
# Security Groups
# ─────────────────────────────────────────────
output "eks_cluster_sg_id" {
  description = "Security group ID for the EKS cluster control plane"
  value       = aws_security_group.eks_cluster.id
}

output "eks_nodes_sg_id" {
  description = "Security group ID for EKS worker nodes"
  value       = aws_security_group.eks_nodes.id
}

output "alb_sg_id" {
  description = "Security group ID for the internet-facing ALB"
  value       = aws_security_group.alb.id
}

output "rds_sg_id" {
  description = "Security group ID for RDS PostgreSQL"
  value       = aws_security_group.rds.id
}

output "redis_sg_id" {
  description = "Security group ID for ElastiCache Redis"
  value       = aws_security_group.redis.id
}

# ─────────────────────────────────────────────
# KMS
# ─────────────────────────────────────────────
output "eks_kms_key_arn" {
  description = "ARN of the KMS key used for EKS secrets encryption"
  value       = aws_kms_key.eks.arn
}

output "app_kms_key_arn" {
  description = "ARN of the KMS key used for S-CORE application PII encryption"
  value       = aws_kms_key.app.arn
}

# ─────────────────────────────────────────────
# IAM — IRSA Roles
# ─────────────────────────────────────────────
output "s_core_app_irsa_role_arn" {
  description = "IRSA role ARN for S-CORE application pods (KMS + Secrets Manager)"
  value       = aws_iam_role.s_core_app.arn
}

output "aws_lb_controller_irsa_role_arn" {
  description = "IRSA role ARN for AWS Load Balancer Controller"
  value       = var.enable_aws_load_balancer_controller ? aws_iam_role.aws_lb_controller[0].arn : null
}

output "cluster_autoscaler_irsa_role_arn" {
  description = "IRSA role ARN for Cluster Autoscaler"
  value       = var.enable_cluster_autoscaler ? aws_iam_role.cluster_autoscaler[0].arn : null
}

# ─────────────────────────────────────────────
# kubectl config helper
# ─────────────────────────────────────────────
output "kubeconfig_command" {
  description = "AWS CLI command to update local kubeconfig"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}