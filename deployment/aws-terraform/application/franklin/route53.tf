# data "aws_route53_zone" "external" {
#   zone_id = var.r53_zone_id
# }

# resource "aws_route53_record" "franklin" {
#   zone_id = data.aws_route53_zone.external.zone_id
#   name    = "${local.franklin_dns_prefix}.${var.r53_public_hosted_zone}"
#   type    = "A"

#   alias {
#     name                   = data.aws_elb.proxy_public.dns_name
#     zone_id                = data.aws_elb.proxy_public.zone_id
#     evaluate_target_health = true
#   }
# }
