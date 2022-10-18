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

variable "cluster_version" {
  type = string
  description = "The Kubernetes version to deploy"
  default = null
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

variable "user_map" {
  type = list(object({username: string, userarn: string, groups: list(string)}))
  description = "A list of {\"username\": string, \"userarn\": string, \"groups\": list(string)} objects describing the users who should have RBAC access to the cluster; note: system:masters should be reserved for those who need the highest level of admin access (including modifying RBAC)"
  default = []
}
