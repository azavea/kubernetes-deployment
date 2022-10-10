module "eks" {
  source = "../../../../modules/aws/cluster"
  cluster_name = local.cluster_name
}
