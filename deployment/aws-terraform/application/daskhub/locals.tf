locals {
  cluster_name = "${var.project_prefix}-${var.environment}"
  cognito_domain = "${var.auth_domain_prefix}.auth.${var.aws_region}.amazoncognito.com"
  jupyter_dns_prefix = var.environment == "production" ? "jupyter" : "${var.environment}.jupyter"

  tags = {
    Name    = var.project_prefix
    Environment = var.environment
    GithubRepo = "kubernetes"
    GithubOrg  = "azavea"
  }
}
