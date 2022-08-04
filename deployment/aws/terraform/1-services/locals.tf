locals {
  cluster_name = "azavea-${var.environment}"

  tags = {
    Name    = "azavea"
    Environment = var.environment
    GithubRepo = "kubernetes"
    GithubOrg  = "azavea"
  }
}
