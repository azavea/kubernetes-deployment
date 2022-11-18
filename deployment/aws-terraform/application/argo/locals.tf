locals {
  cluster_name = "${var.project_prefix}-${var.environment}"
  argo_subdomain = "argo.${var.r53_public_hosted_zone}"

  tags = {
    Name    = var.project_prefix
    Environment = var.environment
    GithubRepo = "kubernetes"
    GithubOrg  = "azavea"
  }
}
