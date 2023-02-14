data "kubernetes_service" "franklin" {
  depends_on = [kubernetes_service.franklin]
  metadata {
    name = "franklin-service"
    namespace = "franklin"
  }
}

data "aws_elb" "franklin" {
  name = replace(
    data.kubernetes_service.franklin.status.0.load_balancer.0.ingress.0.hostname,
    "/-.*/",
    "")
}

data "aws_route53_zone" "external" {
  name = var.r53_public_hosted_zone
}

resource "aws_route53_record" "franklin" {
  zone_id = data.aws_route53_zone.external.zone_id
  name    = local.franklin_subdomain
  type    = "A"

  alias {
    name                   = data.aws_elb.franklin.dns_name
    zone_id                = data.aws_elb.franklin.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "franklin" {
  domain_name = local.franklin_subdomain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "base" {
  for_each = {
    for dvo in aws_acm_certificate.franklin.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.external.zone_id
}

resource "aws_acm_certificate_validation" "franklin" {
  certificate_arn         = aws_acm_certificate.franklin.arn
  validation_record_fqdns = [for record in aws_route53_record.base : record.fqdn]
}
