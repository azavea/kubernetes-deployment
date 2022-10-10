resource "aws_route53_zone" "internal" {
  count = local.db_count
  name = var.r53_rds_private_hosted_zone

  vpc {
    vpc_id     = module.eks.vpc_id
    vpc_region = var.aws_region
  }

  tags = {
    Project = "${var.project_prefix}-kubernetes-${var.environment}"
  }
}

resource "aws_route53_record" "database" {
  count   = local.db_count
  zone_id = aws_route53_zone.internal[0].zone_id
  name    = "database.service.${var.r53_rds_private_hosted_zone}"
  type    = "CNAME"
  ttl     = "10"
  records = [module.database[0].hostname]
}
