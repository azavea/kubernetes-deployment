output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "cluster_name" {
  value = "${var.project_prefix}-${var.environment}"
}
