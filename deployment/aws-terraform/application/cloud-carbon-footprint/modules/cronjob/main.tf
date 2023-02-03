variable "name" {
  type=string
  description="App name"
}

variable "namespace" {
  type=string
  description="App namespace"
}

variable "schedule" {
    type=string
    description="Cron Schedule eg ('0 12 * * 1')"
}

variable "image" {
    type=string
    description="Container image"
}

resource "kubernetes_cron_job" "service" {
  metadata {
    name = var.name
    namespace = var.namespace
  }
  spec {
    schedule = var.schedule
    job_template {
      spec {
        template {
          spec {
            image_pull_secrets {
              name = "regcred"
            }

            container {
              name = var.name
              image = var.image
              resources {
                requests = {
                  cpu = "0.5"
                  memory = "1Gi"
                }
              }
            }
          }
        }        
      }
    }
  }
}