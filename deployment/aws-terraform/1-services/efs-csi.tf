resource "helm_release" "efs_csi_driver" {
  count = local.use_efs
  namespace        = "kube-system"

  name       = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"

  set {
    name  = "controller.serviceAccount.name"
    value = "efs-csi-controller-sa"
  }

  set {
    name  = "node.serviceAccount.name"
    value = "efs-csi-node-sa"
  }

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/eks/aws-efs-csi-driver"
  }
}

resource  "kubernetes_storage_class_v1" "efs_sc" {
  count = local.use_efs

  metadata {
    name = "efs-sc"
  }
  storage_provisioner = "efs.csi.aws.com"

  depends_on = [ helm_release.efs_csi_driver[0] ]
}
