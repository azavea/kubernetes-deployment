resource "aws_cognito_user_pool" "pool" {
  count = local.cognito_pool_count
  name = "${local.cluster_name}-pool"

  username_attributes = ["email"]
}

resource "aws_cognito_user_pool_domain" "domain" {
  count = local.cognito_pool_count
  user_pool_id = aws_cognito_user_pool.pool[0].id
  domain = var.auth_domain_prefix
}

resource "aws_cognito_identity_provider" "provider" {
  count = local.cognito_pool_count
  user_pool_id = aws_cognito_user_pool.pool[0].id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "email"
    client_id = var.google_identity_client_id
    client_secret = var.google_identity_client_secret
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
}
