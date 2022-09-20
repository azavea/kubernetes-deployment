output "cluster_arn" {
  value = module.k8s.cluster.cluster_arn
}

output "cluster_name" {
  value = "azavea-${var.environment}"
}
