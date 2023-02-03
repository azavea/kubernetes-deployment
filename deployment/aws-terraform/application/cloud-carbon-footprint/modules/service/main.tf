variable "name" {
  type=string
  description="App name"
}

variable "namespace" {
  type=string
  description="App namespace"
}

variable "port" {
    type=string
    description="Port"
}

variable "container_port" {
    type=string
    description="Container port"
}

variable "cluster_security_group" {
    type=string
    description="Cluster security group"
}

resource "kubernetes_service" "service" {
  metadata {
    name = var.name
    namespace = var.namespace
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-extra-security-groups" = "${cluster_security_group}"
    }
  }
  spec {
    selector = {
      application = var.name
    }
    port {
      port = var.port
      target_port = var.container_port
      protocol = "TCP"
    }
    type = "LoadBalancer"
  }
}