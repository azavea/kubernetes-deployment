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

variable "franklin_image_tag" {
  type=string
  description="Tag string for Franklin image hosted at quay.io/azavea/franklin"
}

variable "rds_fqdn" {
  type = string
  database = "The fully-qualified domain name of the database host"
}

variable "rds_database_name" {
  type = string
  default = "franklin"
}

variable "rds_database_username" {
  type = string
  sensitive = true
}

variable "rds_database_password" {
  type = string
  sensitive = true
}

variable "r53_zone_id" {
  type = string
  description = "Zone ID of existing hosted zone"
}

variable "r53_public_hosted_zone" {
  type = string
}
