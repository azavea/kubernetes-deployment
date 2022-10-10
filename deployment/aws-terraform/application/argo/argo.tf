resource "helm_release" "argo-workflows" {
  namespace        = "argo"
  create_namespace = true

  name       = "argo-workflows"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-workflows"
  version    = var.argo_workflows_chart_version
}
