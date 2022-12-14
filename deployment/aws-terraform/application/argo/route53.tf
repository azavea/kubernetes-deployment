data "kubernetes_service" "argo_server" {
  depends_on = [helm_release.argo_workflows]
  metadata {
    name = "argo-workflows-server"
    namespace = "argo"
  }
}

data "aws_elb" "argo_server" {
  name = replace(
    data.kubernetes_service.argo_server.status.0.load_balancer.0.ingress.0.hostname,
    "/-.*/",
    "")
}

data "aws_route53_zone" "external" {
  name = var.r53_public_hosted_zone
}

resource "aws_route53_record" "argo_server" {
  zone_id = data.aws_route53_zone.external.zone_id
  name    = local.argo_subdomain
  type    = "A"

  alias {
    name                   = data.aws_elb.argo_server.dns_name
    zone_id                = data.aws_elb.argo_server.zone_id
    evaluate_target_health = true
  }
}
