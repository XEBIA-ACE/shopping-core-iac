# ─────────────────────────────────────────────
# Core
# ─────────────────────────────────────────────
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (dev | staging | production)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "environment must be one of: dev, staging, production."
  }
}

variable "project_name" {
  description = "Project identifier used in resource naming"
  type        = string
  default     = "shopping-core"
}

# ─────────────────────────────────────────────
# VPC / Networking
# ─────────────────────────────────────────────
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs to use (minimum 2 for HA)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets (ALB / NAT)"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDRs for private app subnets (EKS worker nodes)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "private_data_subnet_cidrs" {
  description = "CIDRs for private data subnets (RDS, ElastiCache)"
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
}

variable "mgmt_subnet_cidrs" {
  description = "CIDRs for management / observability subnets"
  type        = list(string)
  default     = ["10.0.30.0/24", "10.0.31.0/24"]
}

# ─────────────────────────────────────────────
# EKS Cluster
# ─────────────────────────────────────────────
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "shopping-core-eks"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS API server endpoint is publicly accessible"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDRs allowed to reach the public API endpoint (if enabled)"
  type        = list(string)
  default     = []
}

# ─────────────────────────────────────────────
# EKS Node Groups
# ─────────────────────────────────────────────
variable "node_groups" {
  description = "Map of EKS managed node group configurations"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string # ON_DEMAND | SPOT
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size_gb   = number
    labels         = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {
    core_api = {
      instance_types = ["m6i.xlarge"]
      capacity_type  = "ON_DEMAND"
      min_size       = 2
      max_size       = 10
      desired_size   = 3
      disk_size_gb   = 50
      labels = {
        workload = "core-api"
        tier     = "app"
      }
      taints = []
    }
    background_worker = {
      instance_types = ["m6i.large"]
      capacity_type  = "ON_DEMAND"
      min_size       = 1
      max_size       = 4
      desired_size   = 2
      disk_size_gb   = 50
      labels = {
        workload = "background-worker"
        tier     = "app"
      }
      taints = []
    }
  }
}

# ─────────────────────────────────────────────
# Add-ons
# ─────────────────────────────────────────────
variable "enable_cluster_autoscaler" {
  description = "Deploy Cluster Autoscaler via Helm"
  type        = bool
  default     = true
}

variable "enable_aws_load_balancer_controller" {
  description = "Deploy AWS Load Balancer Controller"
  type        = bool
  default     = true
}

variable "enable_metrics_server" {
  description = "Deploy Kubernetes Metrics Server"
  type        = bool
  default     = true
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

# ─────────────────────────────────────────────
# KMS
# ─────────────────────────────────────────────
variable "kms_key_deletion_window_days" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 30
}

# ─────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────
variable "cluster_log_retention_days" {
  description = "CloudWatch log retention for EKS control plane logs (days)"
  type        = number
  default     = 90
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

# ─────────────────────────────────────────────
# Tags
# ─────────────────────────────────────────────
variable "additional_tags" {
  description = "Additional tags to merge onto all resources"
  type        = map(string)
  default     = {}
}