resource "kubernetes_namespace" "ccf" {
  metadata {
    name = "ccf"
  }
}

module "api-deployment" {
  depends_on     = [kubernetes_namespace.ccf]
  source         = "modules/deployment"
  name           = "api"
  image          = "279682201306.dkr.ecr.us-east-1.amazonaws.com/btackaberry-ccf-api:latest"
  namespace      = kubernetes_namespace.ccf
  container_port = 80
}

module "api-service" {
  depends_on             = [kubernetes_namespace.ccf]
  source                 = "modules/service"
  name                   = "api"
  namespace              = kubernetes_namespace.ccf
  port                   = 3003
  container_port         = 80
  cluster_security_group = module.eks.cluster_security_group
}

module "dashboard-deployment" {
  depends_on     = [kubernetes_namespace.ccf]
  source         = "modules/deployment"
  name           = "dashboard"
  image          = "279682201306.dkr.ecr.us-east-1.amazonaws.com/btackaberry-ccf-dashboard:latest"
  namespace      = kubernetes_namespace.ccf
  container_port = 80
}

module "dashboard-service" {
  depends_on             = [kubernetes_namespace.ccf]
  source                 = "modules/service"
  name                   = "dashboard"
  namespace              = kubernetes_namespace.ccf
  port                   = 3002
  container_port         = 80
  cluster_security_group = module.eks.cluster_security_group
}

module "ccf-api-deployment" {
  depends_on     = [kubernetes_namespace.ccf]
  source         = "modules/ccf-api-deployment"
  name           = "ccf-api"
  image          = "docker.io/cloudcarbonfootprint/api:release-2022-10-17"
  namespace      = kubernetes_namespace.ccf
  container_port = 4000
}

module "ccf-api-service" {
  depends_on             = [kubernetes_namespace.ccf]
  source                 = "modules/service"
  name                   = "ccf-api"
  namespace              = kubernetes_namespace.ccf
  port                   = 4000
  container_port         = 4000
  cluster_security_group = module.eks.cluster_security_group
}

module "ingest-cronjob" {
  depends_on = [kubernetes_namespace.ccf]
  source     = "modules/cronjob"
  name       = "ccf-api"
  namespace  = kubernetes_namespace.ccf
  image      = "279682201306.dkr.ecr.us-east-1.amazonaws.com/btackaberry-ccf-ingest:latest"
  schedule   = "0 12 * * 1"
}

module "metabase-deployment" {
  depends_on     = [kubernetes_namespace.ccf]
  source         = "modules/metabase-deployment"
  name           = "metabase"
  image          = "metabase/metabase:latest"
  namespace      = kubernetes_namespace.ccf
  container_port = 3000
}

module "metabase-service" {
  depends_on             = [kubernetes_namespace.ccf]
  source                 = "modules/service"
  name                   = "metabase"
  namespace              = kubernetes_namespace.ccf
  port                   = 3000
  container_port         = 3000
  cluster_security_group = module.eks.cluster_security_group
}


resource "aws_iam_role" "ccf" {
  name        = "ccf-irsa"
  description = "IRSA trust policy for Cloud Carbon Footprint (CCF) pods in default service account"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${module.eks.oidc_provider_arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${module.eks.oidc_provider}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
}

module "ccf_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  create_role = true
  role_name   = "ccf"

  role_policy_arns = {
    rds_full_access = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
  }

  oidc_providers = {
    main = {
      provider                   = module.eks.oidc_provider
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["ccf:default"]
    }
  }
}

resource "kubernetes_annotations" "ccf_iam_annotation" {
  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name      = "default"
    namespace = "ccf"
  }
  annotations = {
    "eks.amazonaws.com/role-arn" : aws_iam_role.ccf.arn
  }
}
