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

variable "cluster_version" {
  type = string
  default = "1.23"
}

variable "num_base_instances" {
  type = number
  description = "Number of instances to be provided in the base group"
  default = 1
}

variable "base_instance_type" {
  type = string
  description = "The instance type to use for the always-on core instance running system pods"
  default = "t3.medium"
}

variable "base_instance_capacity_type" {
  type = string
  description = "The capacity type of the always-on core instance (SPOT, ON_DEMAND)"
  default = "ON_DEMAND"
}

variable "user_map" {
  type = list(object({username: string, userarn: string, groups: list(string)}))
  description = "A list of {\"username\": string, \"userarn\": string, \"groups\": list(string)} objects describing the users who should have RBAC access to the cluster; note: system:masters should be used for admin access"
  default = []
}
