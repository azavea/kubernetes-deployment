# The EBS CSI plugin IRSA configs are here, and not in 0—hardware where the EBS
# CSI plugin was installed, because they require the Kubernetes TF provider,
# which needs to be configured with outputs from the 0-hardware stage
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

module "efs_csi_irsa" {
  count = local.use_efs

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name_prefix      = "efs-csi-${local.cluster_name}"
  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:efs-csi-controller-sa"
      ]
    }
  }

  tags = local.tags
}

module "efs_csi_irsa_node" {
  count = local.use_efs

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name_prefix      = "efs-csi-node-${local.cluster_name}"
  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:efs-csi-node-sa"
      ]
    }
  }

  tags = local.tags
}

resource "kubernetes_annotations" "efs_csi_iam_annotation" {
  count = local.use_efs

  api_version = "v1"
  kind = "ServiceAccount"
  metadata {
    name = "efs-csi-controller-sa"
    namespace = "kube-system"
  }
  annotations = {
    "eks.amazonaws.com/role-arn": module.efs_csi_irsa[0].iam_role_arn
  }
}

resource "kubernetes_annotations" "efs_csi_node_annotation" {
  count = local.use_efs

  api_version = "v1"
  kind = "ServiceAccount"
  metadata {
    name = "efs-csi-node-sa"
    namespace = "kube-system"
  }
  annotations = {
    "eks.amazonaws.com/role-arn": module.efs_csi_irsa_node[0].iam_role_arn
  }
}
