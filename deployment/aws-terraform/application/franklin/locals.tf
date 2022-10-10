locals {
  cluster_name = "${var.project_prefix}-${var.environment}"
  franklin_dns_prefix = var.environment == "production" ? "franklin" : "${var.environment}.franklin"

  tags = {
    Name    = var.project_prefix
    Environment = var.environment
    GithubRepo = "kubernetes"
    GithubOrg  = "azavea"
  }
}
