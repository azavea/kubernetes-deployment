output "rds_fqdn" {
  value = var.create_rds_instance ? aws_route53_record.database[0].fqdn : ""
}
