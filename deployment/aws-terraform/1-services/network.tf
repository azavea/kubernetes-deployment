data "aws_vpc" "cluster_vpc" {
  id = module.eks.vpc_id
}

resource "aws_security_group" "efs" {
  name = "EFS inbound"
  description = "EFS inbound traffic"
  vpc_id = module.eks.vpc_id

  ingress {
    description = "NFS traffic"
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    cidr_blocks = [data.aws_vpc.cluster_vpc.cidr_block]
  }

  tags = local.tags
}
