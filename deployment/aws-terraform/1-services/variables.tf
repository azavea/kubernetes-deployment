variable "aws_region" {
  type=string
  description="The AWS region to deploy into.  This will be set by wrapper scripts from the active profile, avoid setting in the .tfvars file"
}

variable "environment" {
  type=string
  description="Name of target environment (e.g., production, staging, QA, etc.).  This will be set by wrapper scripts from the active profile, avoid setting in the .tfvars file"
}

variable "karpenter_chart_version" {
  type = string
  default = "v0.6.3"
}

variable "worker_instance_types" {
  type=list(string)
  description="The menu of node instance types for worker nodes"
}
