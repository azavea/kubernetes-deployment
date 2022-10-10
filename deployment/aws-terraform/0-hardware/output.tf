output "cluster_arn" {
  value = module.k8s.cluster.cluster_arn
}

output "cluster_name" {
  value = "${var.project_prefix}-${var.environment}"
}
