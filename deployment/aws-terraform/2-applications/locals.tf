locals {
  cluster_name = "azavea-${var.environment}"
  franklin_dns_prefix = var.environment == "production" ? "franklin" : "${var.environment}.franklin"

  tags = {
    Name    = "azavea"
    Environment = var.environment
    GithubRepo = "kubernetes"
    GithubOrg  = "azavea"
  }
}
