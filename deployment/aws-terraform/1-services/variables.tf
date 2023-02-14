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

variable "karpenter_chart_version" {
  type = string
  default = "v0.16.3"
}

variable "worker_instance_types" {
  type=list(string)
  description="The menu of node instance types for worker nodes"
}

variable "create_cognito_pool" {
  type = bool
  description = "Flag to determine if a Cognito user pool should be created"
  default = false
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

variable "use_efs_csi" {
  type = bool
  description = "Install EFS CSI driver"
  default = false
}

variable "r53_rds_private_hosted_zone" {
  type = string
  default = null
  description = "The name of the private zone to launch the RDS instance into"
}

variable "create_rds_instance" {
  type = bool
  description = "Flag to determine if an RDS instance should be created"
  default = false
}

variable "rds_secret_namespaces" {
  type = set(string)
  description = "The list of namespaces in which to create the rdsCredentials secret"
  default = []
}

variable "rds_database_identifier" {
  type = string
  default = null
}

variable "rds_database_name" {
  type = string
  default = null
}

variable "rds_database_username" {
  type = string
  sensitive = true
  default = null
}

variable "rds_database_password" {
  type = string
  sensitive = true
  default = null
}

variable "rds_source_snapshot_identifier" {
  type = string
  default = null
}

variable "rds_final_snapshot_identifier" {
  default = "rds-snapshot"
  type    = string
}

variable "rds_allocated_storage" {
  default = 32
  type    = number
}

variable "rds_engine_version" {
  default = 12.8
  type    = number
}

variable "rds_parameter_group_family" {
  default = "postgres12"
  type    = string
}

variable "rds_instance_type" {
  default = "db.t3.micro"
  type    = string
}

variable "rds_storage_type" {
  default = "gp2"
  type    = string
}

variable "rds_backup_retention_period" {
  default = 30
  type    = number
}

variable "rds_backup_window" {
  default = "04:00-04:30"
  type    = string
}

variable "rds_maintenance_window" {
  default = "sun:04:30-sun:05:30"
  type    = string
}

variable "rds_auto_minor_version_upgrade" {
  default = true
  type    = bool
}

variable "rds_monitoring_interval" {
  default = 60
  type    = number
}

variable "rds_skip_final_snapshot" {
  default = false
  type    = bool
}

variable "rds_copy_tags_to_snapshot" {
  default = true
  type    = bool
}

variable "rds_multi_az" {
  default = false
  type    = bool
}

variable "rds_storage_encrypted" {
  default = false
  type    = bool
}

variable "rds_deletion_protection" {
  default = true
  type    = bool
}

variable "rds_log_min_duration_statement" {
  default = 500
  type    = number
}

variable "rds_log_connections" {
  default = 0
  type    = number
}

variable "rds_log_disconnections" {
  default = 0
  type    = number
}

variable "rds_log_lock_waits" {
  default = 1
  type    = number
}

variable "rds_log_temp_files" {
  default = 500
  type    = number
}

variable "rds_log_autovacuum_min_duration" {
  default = 250
  type    = number
}

variable "rds_cpu_threshold_percent" {
  default = 75
  type    = number
}

variable "rds_disk_queue_threshold" {
  default = 10
  type    = number
}

variable "rds_free_disk_threshold_bytes" {
  default = 5000000000
  type    = number
}

variable "rds_free_memory_threshold_bytes" {
  default = 128000000
  type    = number
}

variable "rds_cpu_credit_balance_threshold" {
  default = 30
  type    = number
}
