locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # Merge default + additional tags
  common_tags = merge(
    {
      ManagedBy   = "terraform"
      Project     = var.project_name
      Service     = "S-CORE"
      Environment = var.environment
    },
    var.additional_tags
  )

  # Subnet ID lists (resolved after VPC creation)
  public_subnet_ids      = aws_subnet.public[*].id
  private_app_subnet_ids = aws_subnet.private_app[*].id
  private_data_subnet_ids = aws_subnet.private_data[*].id
  mgmt_subnet_ids        = aws_subnet.mgmt[*].id

  # EKS cluster OIDC issuer (strip https://)
  oidc_issuer_url = replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
}