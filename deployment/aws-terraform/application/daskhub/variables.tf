variable "aws_region" {
  type=string
  description="The AWS region to deploy into.  This will be set by wrapper scripts from the active profile, avoid setting in the .tfvars file"
}

variable "environment" {
  type=string
  description="Name of target environment (e.g., production, staging, QA, etc.).  This will be set by wrapper scripts from the active profile, avoid setting in the .tfvars file"
}

variable "franklin_image_tag" {
  type=string
  description="Tag string for Franklin image hosted at quay.io/azavea/franklin"
}

variable "rds_database_identifier" {
  type = string
}

variable "rds_database_name" {
  type = string
}

variable "rds_database_username" {
  type      = string
  sensitive = true
}

variable "rds_database_password" {
  type      = string
  sensitive = true
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

variable "rds_final_snapshot_identifier" {
  default = "nasahyperspectral-rds-snapshot"
  type    = string
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

variable "r53_zone_id" {
  type = string
  description = "Zone ID of existing hosted zone"
}

variable "r53_public_hosted_zone" {
  type = string
}

variable "r53_private_hosted_zone" {
  type = string
}
