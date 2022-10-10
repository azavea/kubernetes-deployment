data "kubernetes_service" "proxy_public" {
  depends_on = [helm_release.jupyterhub]
  metadata {
    name = "proxy-public"
    namespace = "daskhub"
  }
}

data "aws_elb" "proxy_public" {
  name = replace(
    data.kubernetes_service.proxy_public.status.0.load_balancer.0.ingress.0.hostname,
    "/-.*/",
    "")
}

data "aws_route53_zone" "external" {
  name = var.r53_public_hosted_zone
}

resource "aws_route53_record" "jupyterhub" {
  zone_id = data.aws_route53_zone.external.zone_id
  name    = "${local.jupyter_dns_prefix}.${var.r53_public_hosted_zone}"
  type    = "A"

  alias {
    name                   = data.aws_elb.proxy_public.dns_name
    zone_id                = data.aws_elb.proxy_public.zone_id
    evaluate_target_health = true
  }
}
