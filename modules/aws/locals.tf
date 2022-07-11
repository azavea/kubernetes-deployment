locals {
  region = var.aws_region
  cluster_name = "${var.app_name}-${var.environment}"

  tags = {
    Name    = var.app_name
    GithubRepo = var.repo_name
    GithubOrg  = "azavea"
  }
}
