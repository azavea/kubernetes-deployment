locals {
  cluster_name = "${var.project_prefix}-${var.environment}"

  tags = {
    Name    = var.project_prefix
    Environment = var.environment
    GithubRepo = "kubernetes"
    GithubOrg  = "azavea"
  }
}
