# ─────────────────────────────────────────────
# KMS Key — EKS Secrets Encryption
# ─────────────────────────────────────────────
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

resource "aws_kms_key" "eks" {
  description             = "KMS key for EKS cluster secrets encryption — ${local.name_prefix}"
  deletion_window_in_days = var.kms_key_deletion_window_days
  enable_key_rotation     = true
  multi_region            = false

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowEKSServiceUse"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.aws_region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-eks-kms"
    Purpose = "eks-secrets-encryption"
  })
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${local.name_prefix}-eks"
  target_key_id = aws_kms_key.eks.key_id
}

# ─────────────────────────────────────────────
# KMS Key — Application (PII / Password Crypto)
# Aligns with C-KMS component in S-CORE HLD
# ─────────────────────────────────────────────
resource "aws_kms_key" "app" {
  description             = "KMS key for S-CORE application PII encryption — ${local.name_prefix}"
  deletion_window_in_days = var.kms_key_deletion_window_days
  enable_key_rotation     = true
  multi_region            = false

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowAppNodeAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.eks_node_group.arn
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-app-kms"
    Purpose = "app-pii-encryption"
  })
}

resource "aws_kms_alias" "app" {
  name          = "alias/${local.name_prefix}-app"
  target_key_id = aws_kms_key.app.key_id
}