output "cluster_name" {
  value = local.cluster_name
}

output "cluster" {
  value = module.eks
}

output "vpc" {
  value = module.vpc
}
