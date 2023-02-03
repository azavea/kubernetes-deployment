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
            name = "MB_DB_DBNAME"
            value_from {
              secret_key_ref {
                name = "ccf-config"
                key = "MB_DB_DBNAME"
              }
            }
          }
          env {
            name = "MB_DB_TYPE"
            value_from {
              secret_key_ref {
                name = "ccf-config"
                key = "MB_DB_TYPE"
              }
            }
          }
          env {
            name = "MB_DB_USER"
            value_from {
              secret_key_ref {
                name = "ccf-config"
                key = "MB_DB_USER"
              }
            }
          }
          env {
            name = "MB_DB_PASS"
            value_from {
              secret_key_ref {
                name = "ccf-config"
                key = "MB_DB_PASS"
              }
            }
          }
          env {
            name = "MB_DB_HOST"
            value_from {
              secret_key_ref {
                name = "ccf-config"
                key = "MB_DB_HOST"
              }
            }
          }
          env {
            name = "MB_DB_PORT"
            value_from {
              secret_key_ref {
                name = "ccf-config"
                key = "MB_DB_PORT"
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
