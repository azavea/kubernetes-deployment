locals {
  cluster_name = "${var.project_prefix}-${var.environment}"
  db_count = var.create_rds_instance ? 1 : 0

  tags = {
    Name    = var.project_prefix
    Environment = var.environment
    GithubRepo = "kubernetes"
    GithubOrg  = "azavea"
  }
}
