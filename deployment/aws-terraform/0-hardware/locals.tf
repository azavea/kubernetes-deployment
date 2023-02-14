locals {
  region = var.aws_region
  cluster_name = "${var.project_prefix}-${var.environment}"

  tags = {
    Name    = var.project_prefix
    Environment = var.environment
    GithubRepo = var.repo_name
    GithubOrg  = "azavea"
  }
}
