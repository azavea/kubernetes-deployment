# These EBS-CSI plugin configs are here because they require the Kubernetes TF
# plugin, which needs to be configured with information from the 0-hardware stage
module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "ebs-csi-${local.cluster_name}"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

resource "kubernetes_annotations" "ebs_csi_iam_annotation" {
  api_version = "v1"
  kind = "ServiceAccount"
  metadata {
    name = "ebs-csi-controller-sa"
    namespace = "kube-system"
  }
  annotations = {
    "eks.amazonaws.com/role-arn": module.ebs_csi_irsa.iam_role_arn
  }
}
