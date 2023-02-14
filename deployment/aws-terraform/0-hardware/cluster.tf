# module "k8s" {
#   source="../../../modules/aws/infrastructure"

#   app_name=var.project_prefix
#   environment=var.environment
#   aws_region=var.aws_region
#   cluster_version=var.cluster_version
#   num_base_instances=var.num_base_instances
#   base_instance_type=var.base_instance_type
#   user_map=var.user_map
#   role_map=var.role_map
# }

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "18.31.2"

  cluster_name                    = local.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
    aws-ebs-csi-driver = {}
  }

  # cluster_encryption_config = [{
  #   provider_key_arn = aws_kms_key.eks.arn
  #   resources        = ["secrets"]
  # }]

  cluster_tags = {
    # This should not affect the name of the cluster primary security group
    # Ref: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2006
    # Ref: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2008
    Name = var.project_prefix
    GithubRepo = var.repo_name
    GithubOrg = "azavea"
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # This feature doesn't always work when creating a new cluster from scratch.
  # Allow the cold start flag to dictate if this is our first time applying.
  # Cluster users won't be properly set up until the second go around (cold_start=false).
  manage_aws_auth_configmap = !var.cold_start
  aws_auth_roles = var.role_map
  aws_auth_users = var.user_map

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = [var.base_instance_type]

    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    base = {
      create_launch_template = false
      launch_template_name = ""
      instance_types = [var.base_instance_type]
      capacity_type = var.base_instance_capacity_type
      min_size = 1
      max_size = var.num_base_instances
      desired_size = var.num_base_instances
      labels = {
        node-type = "core"
        "hub.jupyter.org/node-purpose" = "core"
      }
    }
  }

  tags = local.tags
}

# resource "null_resource" "kubectl" {
#   depends_on = [module.eks.kubeconfig]
#   provisioner "local-exec" {
#     command = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_id}"
#   }
# }
