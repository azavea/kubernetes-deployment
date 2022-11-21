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
  description = "Helm chart version to use with Argo (see https://artifacthub.io/packages/helm/argo/argo-workflows)"
  default = "0.20.7"
}

variable "artifact_bucket_prefix" {
  type = string
  description = "Name of the S3 bucket in which to keep artifacts for workflows (will create)"
}

variable "r53_public_hosted_zone" {
  type = string
}

variable "cognito_user_pool_id" {
  type = string
  description = "(Passed in from previous stage; don't set manually)"
}

variable "cognito_user_pool_endpoint" {
  type = string
  description = "(Passed in from previous stage; don't set manually)"
}
