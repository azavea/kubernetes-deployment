resource "kubernetes_namespace" "franklin" {
  metadata {
    name = "franklin"
  }
}

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

        node_selector = {
          "node-type" = "core"
        }

        container {
          image = "quay.io/azavea/franklin:${var.franklin_image_tag}"
          name = "franklin"

          args = [
            "serve",
            "--api-host", "${local.franklin_dns_prefix}.${var.r53_public_hosted_zone}",
            "--api-scheme", "https",
            "--internal-port", "8080",
            "--with-transactions"
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
            value = var.rds_database_name
          }
          env {
            name = "DB_HOST"
            value = var.rds_fqdn #aws_route53_record.database.fqdn
          }
          env {
            name = "DB_PORT"
            value = var.rds_port
          }

          resources {
            requests = {
              cpu = "250m"
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

        init_container {
          image = "${aws_ecr_repository.franklin_db_setup.repository_url}:${var.pgstac_version}"
          name = "db-setup"

          command = [
            "python",
            "/asset/install_pgstac.py",
            "--database-name", var.rds_database_name,
            "--username", var.rds_database_username,
            "--password", var.rds_database_password,
            "--database-host", var.rds_fqdn,
            "--database-port", var.rds_port
          ]
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
      "service.beta.kubernetes.io/aws-load-balancer-extra-security-groups" = module.eks.cluster_security_group
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" = aws_acm_certificate.franklin.arn
    }
  }
  spec {
    selector = {
      application = "franklin"
    }
    port {
      port = 443
      target_port = 8080
    }
    type = "LoadBalancer"
  }
}
