module "argo_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "argo-workflows-${local.cluster_name}"

  role_policy_arns = {
    s3_full_access = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = ["argo:default"]
    }
  }
}

resource "kubernetes_annotations" "argo_iam_annotation" {
  depends_on       = [
    helm_release.argo_workflows
  ]
  api_version = "v1"
  kind = "ServiceAccount"
  metadata {
    namespace = "argo"
    name = "default"
  }
  annotations = {
    "eks.amazonaws.com/role-arn": module.argo_irsa.iam_role_arn
  }
}
