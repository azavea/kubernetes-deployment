output "oidc_issuer_url" {
  value = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "oidc_provider" {
  value = replace(
    data.aws_iam_openid_connect_provider.main.arn,
    "/^[^/]*[/]/",
    ""
  )
}

output "oidc_provider_arn" {
  value = data.aws_iam_openid_connect_provider.main.arn
}

output "base_node_iam_role_arn" {
  value = data.aws_eks_node_group.base.node_role_arn
}

output "base_node_iam_role_name" {
  value = split("/", data.aws_eks_node_group.base.node_role_arn)[1]
}

output "endpoint" {
  value = data.aws_eks_cluster.main.endpoint
}

output "id" {
  value = data.aws_eks_cluster.main.id
}

output "cluster_certificate_authority_data" {
  value = data.aws_eks_cluster.main.certificate_authority[0].data
}
