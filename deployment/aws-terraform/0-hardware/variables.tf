variable "aws_region" {
  type=string
  description="The AWS region to deploy into.  This will be set by wrapper scripts from the active profile, avoid setting in the .tfvars file"
}

variable "environment" {
  type=string
  description="Name of target environment (e.g., production, staging, QA, etc.).  This will be set by wrapper scripts from the active profile, avoid setting in the .tfvars file"
}

variable "project_prefix" {
  type=string
  description="The project name prefix used to identify cluster resources.  This will be set by wrapper scripts; avoid setting in the .tfvars file!"
}

variable "repo_name" {
  type = string
  description = "Name of the Github repo hosting the deployment (for tagging)"
  default = "kubernetes"
}

variable "cluster_version" {
  type = string
  description = "The Kubernetes version to deploy"
  default = null
}

variable "cold_start" {
  type = bool
  description = "A flag to indicate that this is the first time we are applying this base infrastructure; not all features are applied correctly for a brand new cluster; run once with this variable set to true; subsequent runs should set this to false"
  default = false
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
  description = "A list of {\"username\": string, \"userarn\": string, \"groups\": list(string)} objects describing the users who should have RBAC access to the cluster; note: system:masters should be reserved for those who need the highest level of admin access (including modifying RBAC)"
  default = []
}

variable "role_map" {
  type = list(object({rolearn: string, username: string, groups: list(string)}))
  description = "A list of {\"rolearn\": string, \"username\": string, \"groups\": list(string)} objects describing the mapping of IAM roles to cluster users who should have RBAC access to the cluster; note: system:masters should be used for admin access"
  default = []
}
