# ─────────────────────────────────────────────
# CloudWatch Log Groups — Application
# Aligns with C-LOGGING-MONITORING component
# ─────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/eks/${var.cluster_name}/shopping-core/app"
  retention_in_days = var.cluster_log_retention_days
  kms_key_id        = aws_kms_key.eks.arn

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-app-logs"
    Component = "S-CORE-Application"
  })
}

resource "aws_cloudwatch_log_group" "access" {
  name              = "/aws/eks/${var.cluster_name}/shopping-core/access"
  retention_in_days = var.cluster_log_retention_days
  kms_key_id        = aws_kms_key.eks.arn

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-access-logs"
    Component = "S-CORE-AccessLogs"
  })
}

# ─────────────────────────────────────────────
# CloudWatch Alarms — Core SLOs
# ─────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "node_cpu_high" {
  alarm_name          = "${local.name_prefix}-node-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EKS node CPU utilization > 80% for 3 consecutive minutes"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_eks_cluster.main.name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "node_memory_high" {
  alarm_name          = "${local.name_prefix}-node-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "node_memory_utilization"
  namespace           = "ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EKS node memory utilization > 80% for 3 consecutive minutes"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_eks_cluster.main.name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "pod_restart_high" {
  alarm_name          = "${local.name_prefix}-pod-restart-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "pod_number_of_container_restarts"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "S-CORE pod restart count > 5 in 5 minutes — possible crash loop"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_eks_cluster.main.name
    Namespace   = "shopping-core"
  }

  tags = local.common_tags
}