variable "aws_region" {
  type=string
  description="The AWS region to deploy into"
}

variable "app_name" {
  default = "k8s-application"
}

variable "environment" {
  type = string
  description = "Name of target environment (e.g., production, staging, QA, etc.)"
}

variable "repo_name" {
  type = string
  description = "Name of the Github repo hosting the deployment (for tagging)"
  default = "kubernetes"
}

variable "karpenter_version" {
  type = string
  default = "v0.5.3"
}

variable "karpenter_instance_types" {
  type = list
  default = ["m4.xlarge", "m6i.large", "m5.large", "m5n.large", "m5zn.large"]
}
