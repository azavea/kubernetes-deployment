variable "name" {
  type=string
  description="App name"
}

variable "namespace" {
  type=string
  description="App namespace"
}

variable "image" {
    type=string
    description="Container image"
}

variable "container_port" {
    type=string
    description="Container port"
}


resource "kubernetes_deployment" "deployment" {
  metadata {
    name = var.name
    namespace = var.namespace
    labels = {
      application = var.name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        application = var.name
      }
    }

    template {
      metadata {
        labels = {
          application = var.name
        }
      }

      spec {
        service_account_name = "default"

        container {
          image = var.image
          name = var.name

          env {
            name = "AWS_USE_BILLING_DATA"
            value_from {
              secret_key_ref {
                name = "ccf-config"
                key = "AWS_USE_BILLING_DATA"
              }
            }
          }
          env {
            name = "AWS_ATHENA_QUERY_RESULT_LOCATION"
            value_from {
              secret_key_ref {
                name = "ccf-config"
                key = "AWS_ATHENA_QUERY_RESULT_LOCATION"
              }
            }
          }
          env {
            name = "AWS_ATHENA_DB_TABLE"
            value_from {
              secret_key_ref {
                name = "ccf-config"
                key = "AWS_ATHENA_DB_TABLE"
              }
            }
          }
          env {
            name = "AWS_ATHENA_DB_NAME"
            value_from {
              secret_key_ref {
                name = "ccf-config"
                key = "AWS_ATHENA_DB_NAME"
              }
            }
          }
          env {
            name = "AWS_TARGET_ACCOUNT_ROLE_NAME"
            value_from {
              secret_key_ref {
                name = "ccf-config"
                key = "AWS_TARGET_ACCOUNT_ROLE_NAME"
              }
            }
          }
          env {
            name = "AWS_BILLING_ACCOUNT_NAME"
            value_from {
              secret_key_ref {
                name = "ccf-config"
                key = "AWS_BILLING_ACCOUNT_NAME"
              }
            }
          }
          env {
            name = "AWS_BILLING_ACCOUNT_ID"
            value_from {
              secret_key_ref {
                name = "ccf-config"
                key = "AWS_BILLING_ACCOUNT_ID"
              }
            }
          }
          env {
            name = "AWS_ATHENA_REGION"
            value_from {
              secret_key_ref {
                name = "ccf-config"
                key = "AWS_ATHENA_REGION"
              }
            }
          }

          resources {
            requests = {
              cpu = "0.5"
              memory = "1Gi"
            }
          }

          port {
            container_port = var.container_port
            protocol = "TCP"
            name = "http"
          }

        }
      }
    }
  }
}
