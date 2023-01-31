locals {
  cluster_name = "${var.project_prefix}-${var.environment}"
  db_count = var.create_rds_instance ? 1 : 0
  cognito_pool_count = var.create_cognito_pool ? 1 : 0
  use_efs = var.use_efs_csi ? 1 : 0

  tags = {
    Name    = var.project_prefix
    Environment = var.environment
    GithubRepo = "kubernetes"
    GithubOrg  = "azavea"
  }
}
