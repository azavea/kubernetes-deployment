resource "random_id" "daskhub_token" {
  byte_length = 32
}

resource "helm_release" "jupyterhub" {
  depends_on       = [
    module.eks.kubeconfig
  ]
  namespace        = "daskhub"
  create_namespace = true

  name       = "jupyterhub"
  repository = "https://jupyterhub.github.io/helm-chart/"
  chart      = "jupyterhub"
  version    = "1.2.0"
  timeout    = 600

  # All static settings belong in the following YAML
  values = [
    "${file("yaml/jupyterhub-values.yaml")}"
  ]

  # Settings which depend on Terraform resources should be set separately
  set {
    name  = "hub.services.dask-gateway.apiToken"
    value = random_id.daskhub_token.hex
  }

  set {
    name  = "proxy.secretToken"
    value = random_id.daskhub_token.hex
  }

  set {
    name = "singleuser.image.name"
    value = aws_ecr_repository.pangeo_s3contents.repository_url
  }

  set {
    name = "singleuser.image.tag"
    value = var.pangeo_notebook_version
  }

  set {
    name = "proxy.https.hosts[0]"
    value = "${local.jupyter_dns_prefix}.${var.r53_public_hosted_zone}"
  }

  set {
    name = "proxy.https.letsencrypt.contactEmail"
    value = var.letsencrypt_contact_email
  }

  set {
    name = "hub.extraEnv.OAUTH_CALLBACK_URL"
    value = "https://${local.jupyter_dns_prefix}.${var.r53_public_hosted_zone}/hub/oauth_callback"
  }

  set {
    name = "hub.extraEnv.OAUTH2_AUTHORIZE_URL"
    value = "https://${local.cognito_domain}/oauth2/authorize"
  }

  set {
    name = "hub.extraEnv.OAUTH2_TOKEN_URL"
    value = "https://${local.cognito_domain}/oauth2/token"
  }

  set {
    name = "hub.extraEnv.OAUTH2_USERDATA_URL"
    value = "https://${local.cognito_domain}/oauth2/userInfo"
  }

  set {
    name = "hub.config.GenericOAuthenticator.client_id"
    value = aws_cognito_user_pool_client.client.id
  }

  set {
    name = "hub.config.GenericOAuthenticator.client_secret"
    value = aws_cognito_user_pool_client.client.client_secret
  }
}

resource "helm_release" "dask_gateway" {
  depends_on       = [
    module.eks.kubeconfig,
    helm_release.jupyterhub
  ]
  namespace        = "daskhub"
  create_namespace = true

  name       = "dask-gateway"
  repository = "https://helm.dask.org/"
  chart      = "dask-gateway"
  version    = "2022.4.0"

  # All static settings belong in the following YAML
  values = [
    "${file("yaml/dask-gateway-values.yaml")}"
  ]

  # Settings which depend on Terraform resources should be set separately
  set {
    name  = "gateway.auth.jupyterhub.apiToken"
    value = random_id.daskhub_token.hex
  }

  set {
    name = "gateway.backend.image.name"
    value = aws_ecr_repository.pangeo_s3contents.repository_url
  }

  set {
    name = "gateway.backend.image.tag"
    value = var.pangeo_notebook_version
  }
}
