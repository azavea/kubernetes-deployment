provider "aws" {}

variable "cluster_name" {
  type = string
}

module "eks" {
  source = "../../../../modules/aws/cluster"
  cluster_name = var.cluster_name
}

output "cluster_info" {
  value = module.eks
}
