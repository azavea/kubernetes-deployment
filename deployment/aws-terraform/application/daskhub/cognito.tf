resource "aws_cognito_resource_server" "resource" {
  identifier = "https://${local.jupyter_dns_prefix}.${var.r53_public_hosted_zone}"
  name = "${local.cluster_name}-resource-server"

  user_pool_id = var.cognito_user_pool_id

  scope {
    scope_name = "read_product"
    scope_description = "Read product details"
  }

  scope {
    scope_name = "create_product"
    scope_description = "Create a new product"
  }

  scope {
    scope_name = "delete_product"
    scope_description = "Delete a product"
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "${local.cluster_name}-jupyter-client"

  generate_secret = true
  user_pool_id = var.cognito_user_pool_id

  callback_urls = ["https://${local.jupyter_dns_prefix}.${var.r53_public_hosted_zone}/hub/oauth_callback"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = ["code", "implicit"]
  allowed_oauth_scopes = ["email", "openid"]
  supported_identity_providers = ["COGNITO", "Google"]
}
