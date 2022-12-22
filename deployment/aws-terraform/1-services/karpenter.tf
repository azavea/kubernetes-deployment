data "aws_iam_policy" "ssm_managed_instance" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "karpenter_ssm_policy" {
  role       = module.eks.base_node_iam_role_name
  policy_arn = data.aws_iam_policy.ssm_managed_instance.arn
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${local.cluster_name}"
  role = module.eks.base_node_iam_role_name
}

module "iam_assumable_role_karpenter" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.7.0"
  create_role                   = true
  role_name                     = "karpenter-controller-${local.cluster_name}"
  provider_url                  = module.eks.oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:karpenter:karpenter"]
}

resource "aws_iam_role_policy" "karpenter_controller" {
  name = "karpenter-policy-${local.cluster_name}"
  role = module.iam_assumable_role_karpenter.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "iam:PassRole",
          "ec2:TerminateInstances",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ssm:GetParameter",
          "pricing:GetProducts",
          "ec2:DescribeSpotPriceHistory"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = var.karpenter_chart_version

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_karpenter.iam_role_arn
  }

  set {
    name  = "clusterName"
    value = local.cluster_name
  }

  set {
    name  = "clusterEndpoint"
    value = module.eks.endpoint
  }

  set {
    name = "logLevel"
    value = "info"
  }
}

module "karpenter_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                          = "karpenter-controller"
  attach_karpenter_controller_policy = true

  karpenter_tag_key = "karpenter.sh/discovery/${local.cluster_name}"
  karpenter_controller_cluster_id = module.eks.id
  karpenter_controller_node_iam_role_arns = [module.eks.base_node_iam_role_arn]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }

  tags = local.tags
}

# Here, we set the behavior of Karpenter; see https://karpenter.sh/v0.6.3/aws/provisioning/
resource "kubectl_manifest" "karpenter_provisioner" {
  yaml_body = <<-YAML
  apiVersion: karpenter.sh/v1alpha5
  kind: Provisioner
  metadata:
    name: default
  spec:
    labels:
      node-type: worker
      hub.jupyter.org/node-purpose: user
    requirements:
      - key: karpenter.sh/capacity-type
        operator: In
        values: ["spot"]
      - key: node.kubernetes.io/instance-type
        operator: In
        values: ${jsonencode(var.worker_instance_types)}
    limits:
      resources:
        cpu: 1000
    providerRef:
      name: default
    ttlSecondsAfterEmpty: 30
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

# Here, we set the behavior of Karpenter; see https://karpenter.sh/v0.6.3/aws/provisioning/
resource "kubectl_manifest" "karpenter_provisioner_big" {
  yaml_body = <<-YAML
  apiVersion: karpenter.sh/v1alpha5
  kind: Provisioner
  metadata:
    name: big-disk
  spec:
    labels:
      node-type: worker
      hub.jupyter.org/node-purpose: user
      disk-size: large
    requirements:
      - key: karpenter.sh/capacity-type
        operator: In
        values: ["spot"]
      - key: node.kubernetes.io/instance-type
        operator: In
        values: ${jsonencode(var.worker_instance_types)}
    limits:
      resources:
        cpu: 1000
    providerRef:
      name: big-disk
    ttlSecondsAfterEmpty: 30
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_node_template" {
  yaml_body = <<-YAML
  apiVersion: karpenter.k8s.aws/v1alpha1
  kind: AWSNodeTemplate
  metadata:
    name: default
  spec:
    subnetSelector:
      kubernetes.io/cluster/${local.cluster_name}: '*'
    securityGroupSelector:
      "aws:eks:cluster-name": ${local.cluster_name}
    tags:
      ${var.project_prefix}/kubernetes: 'provisioner'
      karpenter.sh/discovery/${module.eks.id}: ${module.eks.id}
    instanceProfile:
      KarpenterNodeInstanceProfile-${local.cluster_name}
  YAML

  depends_on = [
    kubectl_manifest.karpenter_provisioner
  ]
}

resource "kubectl_manifest" "karpenter_node_template_big_disk" {
  yaml_body = <<-YAML
  apiVersion: karpenter.k8s.aws/v1alpha1
  kind: AWSNodeTemplate
  metadata:
    name: big-disk
  spec:
    subnetSelector:
      kubernetes.io/cluster/${local.cluster_name}: '*'
    securityGroupSelector:
      "aws:eks:cluster-name": ${local.cluster_name}
    tags:
      ${var.project_prefix}/kubernetes: 'provisioner'
      karpenter.sh/discovery/${module.eks.id}: ${module.eks.id}
    instanceProfile:
      KarpenterNodeInstanceProfile-${local.cluster_name}
    blockDeviceMappings:
      - deviceName: /dev/xvda
        ebs:
          volumeSize: 128Gi
  YAML

  depends_on = [
    kubectl_manifest.karpenter_provisioner
  ]
}
