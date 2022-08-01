data "aws_eks_cluster" "main" {
  name = var.cluster_name
}

data "aws_eks_node_groups" "ngs" {
  cluster_name = var.cluster_name
}

data "aws_eks_node_group" "base" {
  cluster_name = var.cluster_name
  node_group_name = [for ng in data.aws_eks_node_groups.ngs.names : ng if length(regexall("base.*", ng)) > 0][0]
}

data "aws_iam_openid_connect_provider" "main" {
  url = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
}
