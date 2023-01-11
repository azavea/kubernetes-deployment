data "aws_vpc" "cluster_vpc" {
  id = module.eks.vpc_id
}

resource "aws_efs_file_system" "noaa" {
  creation_token = "noaa-hydro-data"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

resource "aws_efs_mount_target" "noaa" {
  for_each = toset( module.eks.vpc_private_subnet_ids )
  file_system_id = aws_efs_file_system.noaa.id
  subnet_id = each.key
  security_groups = [ module.eks.cluster_security_group ]
}
