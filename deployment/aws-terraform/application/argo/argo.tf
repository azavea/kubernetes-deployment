resource "kubernetes_namespace" "argo" {
  metadata {
    name = "argo"
  }
}

resource "kubernetes_secret" "argo_oauth" {
  metadata {
    name = "argo-server-oauth"
    namespace = "argo"
  }

  data = {
    client_id = aws_cognito_user_pool_client.client.id
    client_secret = aws_cognito_user_pool_client.client.client_secret
  }
}

resource "helm_release" "argo_workflows" {
  namespace        = "argo"

  name       = "argo-workflows"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-workflows"
  version    = var.argo_workflows_chart_version

  values = [
    "${file("yaml/argo-workflows-values.yaml")}"
  ]

  set {
    name = "server.sso.redirectUrl"
    value = "https://${local.argo_subdomain}/oauth2/callback"
  }

  set {
    name = "server.sso.issuer"
    value = "https://${var.cognito_user_pool_endpoint}"
  }

  set {
    name = "artifactRepository.s3.bucket"
    value = var.artifact_bucket_name
  }
}
