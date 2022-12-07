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

variable "auth_domain_prefix" {
  type = string
  description = "Domain prefix for Cognito OAuth"
}

variable "google_identity_client_id" {
  type = string
  description = "Client ID for Google identity provider"
}

variable "google_identity_client_secret" {
  type = string
  description = "Client ID for Google identity provider"
}

variable "jupyter_notebook_s3_bucket" {
  type = string
  description = "The name of the bucket in which to store user notebooks"
}

variable "letsencrypt_contact_email" {
  type = string
  description = "Contact email for Let's Encrypt (jupyterhub HTTPS certificate provider)"
}

variable "pangeo_notebook_version" {
  type = string
  description = "Version of pangeo-notebook image"
  default = "2022.05.18"
}

variable "r53_public_hosted_zone" {
  type = string
  description = "Hosted zone name for this application"
}
