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
    namespace = "ccf"
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

        image_pull_secrets {
          name = "regcred"
        }

        container {
          image = var.image
          name = var.name

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
