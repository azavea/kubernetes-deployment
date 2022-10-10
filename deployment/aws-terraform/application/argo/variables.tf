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

variable "argo_workflows_chart_version" {
  type = string
  default = "0.16.8"
}
