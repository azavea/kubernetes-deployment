module "k8s" {
  source="../../../modules/aws/infrastructure"

  app_name="azavea"
  environment=var.environment
  aws_region=var.aws_region
  num_base_instances=var.num_base_instances
  base_instance_type=var.base_instance_type
  user_map=var.user_map
}
