module "eks" {
  source = "../../../../modules/aws/cluster"
  cluster_name = var.cluster_name
}
