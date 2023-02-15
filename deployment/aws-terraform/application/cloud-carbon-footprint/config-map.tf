variable "CCF_AWS_USE_BILLING_DATA" {}
variable "CCF_CCF_AWS_BILLING_ACCOUNT_ID" {}
variable "CCF_AWS_BILLING_ACCOUNT_NAME" {}
variable "CCF_AWS_ATHENA_REGION" {}
variable "CCF_AWS_TARGET_ACCOUNT_ROLE_NAME" {}
variable "CCF_AWS_ATHENA_DB_NAME" {}
variable "CCF_AWS_ATHENA_DB_TABLE" {}
variable "CCF_AWS_ATHENA_QUERY_RESULT_LOCATION" {}
variable "CCF_POSTGRES_USER" {}
variable "CCF_POSTGRES_PASSWORD" {}
variable "CCF_POSTGRES_DB" {}
variable "CCF_POSTGRES_HOST" {}
variable "CCF_POSTGRES_PORT" {}
variable "CCF_WORKSHEET_ID" {}
variable "CCF_MB_DB_TYPE" {}
variable "CCF_MB_DB_DBNAME" {}
variable "CCF_MB_DB_PORT" {}
variable "CCF_MB_DB_USER" {}
variable "CCF_MB_DB_PASS" {}
variable "CCF_MB_DB_HOST" {}

resource "kubernetes_config_map" "config_map" {
  metadata {
    name      = "ccf-config"
    namespace = "ccf"
  }

  data = {
    AWS_USE_BILLING_DATA             = var.CCF_AWS_USE_BILLING_DATA
    AWS_BILLING_ACCOUNT_ID           = var.CCF_CCF_AWS_BILLING_ACCOUNT_ID
    AWS_BILLING_ACCOUNT_NAME         = var.CCF_AWS_BILLING_ACCOUNT_NAME
    AWS_ATHENA_REGION                = var.CCF_AWS_ATHENA_REGION
    AWS_TARGET_ACCOUNT_ROLE_NAME     = var.CCF_AWS_TARGET_ACCOUNT_ROLE_NAME
    AWS_ATHENA_DB_NAME               = var.CCF_AWS_ATHENA_DB_NAME
    AWS_ATHENA_DB_TABLE              = var.CCF_AWS_ATHENA_DB_TABLE
    AWS_ATHENA_QUERY_RESULT_LOCATION = var.CCF_AWS_ATHENA_QUERY_RESULT_LOCATION
    POSTGRES_USER                    = var.CCF_POSTGRES_USER
    POSTGRES_PASSWORD                = var.CCF_POSTGRES_PASSWORD
    POSTGRES_DB                      = var.CCF_POSTGRES_DB
    POSTGRES_HOST                    = var.CCF_POSTGRES_HOST
    POSTGRES_PORT                    = var.CCF_POSTGRES_PORT
    WORKSHEET_ID                     = var.CCF_WORKSHEET_ID
    MB_DB_TYPE                       = var.CCF_MB_DB_TYPE
    MB_DB_DBNAME                     = var.CCF_MB_DB_DBNAME
    MB_DB_PORT                       = var.CCF_MB_DB_PORT
    MB_DB_USER                       = var.CCF_MB_DB_USER
    MB_DB_PASS                       = var.CCF_MB_DB_PASS
    MB_DB_HOST                       = var.CCF_MB_DB_HOST
  }
}
