output "rds_fqdn" {
  value = var.create_rds_instance ? aws_route53_record.database[0].fqdn : ""
}

output "cognito_user_pool_id" {
  value = var.create_cognito_pool ? aws_cognito_user_pool.pool[0].id : null
}

output "cognito_user_pool_endpoint" {
  value = var.create_cognito_pool ? aws_cognito_user_pool.pool[0].endpoint : null
}
