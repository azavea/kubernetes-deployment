resource "kubernetes_namespace" "franklin" {
  metadata {
    name = "franklin"
  }
}

# resource "kubernetes_service_account" "franklin" {
#   metadata {
#     name = "default"
#     namespace = "franklin"
#   }
# }

resource "kubernetes_deployment" "franklin" {
  depends_on = [kubernetes_namespace.franklin]
  metadata {
    name = "franklin"
    namespace = "franklin"
    labels = {
      application = "franklin"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        application = "franklin"
      }
    }

    template {
      metadata {
        labels = {
          application = "franklin"
        }
      }

      spec {
        service_account_name = "default"

        container {
          image = "quay.io/azavea/franklin:${var.franklin_image_tag}"
          name = "franklin"

          args = [
            "serve",
            "--api-host", "${local.franklin_dns_prefix}.${var.r53_public_hosted_zone}",
            "--api-scheme", "http",
            "--internal-port", "8080",
            "--with-transactions",
            "--with-tiles",
            "--run-migrations"
          ]

          env {
            name = "DB_USER"
            value = var.rds_database_username
          }
          env {
            name = "DB_PASSWORD"
            value = var.rds_database_password
          }
          env {
            name = "DB_NAME"
            value = "franklin"
          }
          env {
            name = "DB_HOST"
            value = aws_route53_record.database.fqdn
          }
          env {
            name = "DB_PORT"
            value = module.database.port
          }

          resources {
            requests = {
              cpu = "0.5"
              memory = "1Gi"
            }
          }

          port {
            container_port = 8080
          }

          # liveness_probe {
          #   http_get {
          #     path = "/open-api/spec.yaml"
          #     port = 443
          #   }

          #   initial_delay_seconds = 3
          #   period_seconds = 30
          # }
        }
      }
    }
  }
}

resource "kubernetes_service" "franklin" {
  depends_on = [kubernetes_namespace.franklin]
  metadata {
    name = "franklin-service"
    namespace = "franklin"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-extra-security-groups" = "${module.eks.cluster_security_group}"
    }
  }
  spec {
    selector = {
      application = "franklin"
    }
    port {
      port = 80
      target_port = 8080
    }
    type = "LoadBalancer"
  }
}

resource "aws_iam_role" "franklin" {
  name = "franklin-irsa"
  description = "IRSA trust policy for Franklin pods in default service account"

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

module "franklin_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  create_role = true
  role_name = "franklin"

  role_policy_arns = {
    #s3_full_access = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    rds_full_access = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
  }

  oidc_providers = {
    main = {
      provider = module.eks.oidc_provider
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = ["franklin:default"]
    }
  }
}

resource "kubernetes_annotations" "franklin_iam_annotation" {
  api_version = "v1"
  kind = "ServiceAccount"
  metadata {
    name = "default"
    namespace = "franklin"
  }
  annotations = {
    "eks.amazonaws.com/role-arn": aws_iam_role.franklin.arn
  }
}
