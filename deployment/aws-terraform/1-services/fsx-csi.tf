resource "helm_release" "fsx_csi_driver" {
  count = local.use_fsx
  namespace        = "kube-system"

  name       = "aws-fsx-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-fsx-csi-driver/"
  chart      = "aws-fsx-csi-driver"

  set {
    name = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.fsx_csi_irsa[0].iam_role_arn
  }

  set {
    name = "node.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.fsx_csi_irsa[0].iam_role_arn
  }
}

resource  "kubernetes_storage_class_v1" "fsx_sc" {
  count = local.use_fsx
  metadata {
    name = "fsx-sc"
  }
  storage_provisioner = "fsx.csi.aws.com"
  parameters = {
    subnetId = tolist(module.eks.vpc_private_subnet_ids)[0]
    securityGroupIds = module.eks.cluster_security_group
    deploymentType = "PERSISTENT_2"
  }
  depends_on = [ helm_release.fsx_csi_driver[0] ]
}
