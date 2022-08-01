provider "aws" {}

terraform {
  backend "s3" {
    region = local.region
    encrypt = "true"
  }
}

provider "kubernetes" {
  # host                   = module.k8s.cluster.cluster_endpoint
  # cluster_ca_certificate = base64decode(module.k8s.cluster.cluster_certificate_authority_data)

  # exec {
  #   api_version = "client.authentication.k8s.io/v1beta1"
  #   command     = "aws"
  #   # This requires the awscli to be installed locally where Terraform is executed
  #   args = ["eks", "get-token", "--cluster-name", local.cluster_name]
  # }
}

provider "helm" {
  kubernetes {
    host                   = module.k8s.cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.k8s.cluster.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
      command     = "aws"
    }
  }
}

# data "aws_caller_identity" "this" {}
# data "aws_ecr_authorization_token" "token" {}

# provider "docker" {
#   host = "unix:///var/run/docker.sock"

#   registry_auth {
#     address  = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.this.account_id, var.aws_region)
#     username = data.aws_ecr_authorization_token.token.user_name
#     password = data.aws_ecr_authorization_token.token.password
#     config_file = pathexpand("~/.docker/config.json")
#   }
# }
