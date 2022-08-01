module "eks" {
  source = "../cluster"
  cluster_name = local.cluster_name
}
