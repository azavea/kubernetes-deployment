resource "aws_iam_role" "daskhub" {
  name = "daskhub-irsa"
  description = "IRSA trust policy for Daskhub pods in default service account"

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
          "${module.eks.oidc_provider}:aud": "sts.amazonaws.com",
          "${module.eks.oidc_provider}:sub": "system:serviceaccount:daskhub:default"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "irsa_s3_full_access" {
  role = aws_iam_role.daskhub.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"

  depends_on = [helm_release.jupyterhub]
}

module "daskhub_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  create_role = true
  role_name = "daskhub"

  role_policy_arns = {
    s3_full_access = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }

  oidc_providers = {
    main = {
      provider = module.eks.oidc_provider
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = ["daskhub:default"]
    }
  }
}

resource "kubernetes_annotations" "daskhub_iam_annotation" {
  depends_on       = [
    helm_release.dask_gateway
  ]
  api_version = "v1"
  kind = "ServiceAccount"
  metadata {
    name = "default"
    namespace = "daskhub"
  }
  annotations = {
    "eks.amazonaws.com/role-arn": aws_iam_role.daskhub.arn
  }
}
