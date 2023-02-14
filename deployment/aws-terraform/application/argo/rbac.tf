# This file can be customized to include rules for mapping users to service accounts
resource "kubernetes_service_account_v1" "default_rbac" {
  metadata {
    name = "argo-read-write-user"
    namespace = "argo"
    annotations = {
      "workflows.argoproj.io/rbac-rule" = "true"
      "workflows.argoproj.io/rbac-rule-precedence" = "0"
    }
  }
}
