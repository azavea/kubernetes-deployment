locals {
  cluster_name = "${var.project_prefix}-${var.environment}"
  franklin_dns_prefix = var.environment == "production" ? "franklin" : "franklin-${var.environment}"
  franklin_subdomain = "${local.franklin_dns_prefix}.${var.r53_public_hosted_zone}"

  tags = {
    Name    = var.project_prefix
    Environment = var.environment
    GithubRepo = "kubernetes"
    GithubOrg  = "azavea"
  }
}
