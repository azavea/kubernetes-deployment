resource "kubernetes_secret" "rds" {
  for_each = var.create_rds_instance ? var.rds_secret_namespaces : []

  metadata {
    name = "rds-credentials"
    namespace = each.key
  }

  data = {
    username = var.rds_database_username
    password = var.rds_database_password
    host = var.create_rds_instance ? aws_route53_record.database[0].fqdn : ""
  }
}
