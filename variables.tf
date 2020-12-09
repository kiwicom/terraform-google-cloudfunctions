variable "sls_project_name" {
  type        = string
  description = "Project name composed of {project_name}-{project_env}, stored in CI/CD env variables"
}

variable "function_name" {
  type        = string
  description = "Function name. If empty, it defaults to {var.sls_project_name}-{var.entry_point}"
  default     = ""
}

variable "cf_src_bucket" {
  type        = string
  description = "Source archive bucket for Cloud Functions, stored in CI/CD env variables"
}

variable "source_dir" {
  type        = string
  description = "Location of source code to deploy, without a leading slash"
  default     = ""
}

variable "entry_point" {
  type        = string
  description = "Name of the function that will be executed when the Google Cloud Function is triggered"
}

variable "trigger_type" {
  type        = string
  description = "Function trigger type that must be provided"

  validation {
    condition     = can(regex("^(http|topic|scheduler|bucket)$", var.trigger_type))
    error_message = "Possible values are: http, topic, scheduler or bucket."
  }
}

variable "trigger_event_type" {
  type        = string
  description = "The type of event to observe. Only for topic and bucket triggered functions"
  default     = ""
}

variable "trigger_event_resource" {
  type        = string
  description = "The name or partial URI of the resource from which to observe events. Only for topic and bucket triggered functions"
  default     = ""
}

variable "project" {
  type        = string
  description = "Google Cloud Platform project id, stored in CI/CD env variables"
}

variable "region" {
  type        = string
  default     = "europe-west3"
  description = "Region for Cloud Functions and accompanying resources"
}

variable "region_app_engine" {
  type        = string
  description = "Region for App Engine (Scheduler). If not provided, defaults to region set above"
  default     = ""
}

variable "runtime" {
  type        = string
  description = "The runtime in which the function is going to run. Eg. 'nodejs10', `nodejs12`, 'python37', 'python38', 'go113'"
}

variable "available_memory_mb" {
  type        = string
  description = "Memory (in MB), available to the function. Default value is 256MB. Allowed values are: 128MB, 256MB, 512MB, 1024MB, and 2048MB"
}

variable "timeout" {
  type        = number
  description = "Timeout (in seconds) for the function. Default value is 60 seconds. Cannot be more than 540 seconds"
  default     = 60
}

variable "max_instances" {
  type        = number
  description = "The limit on the maximum number of function instances that may coexist at a given time"
  default     = 0
}

variable "service_account_email" {
  type        = string
  description = "Self-provided service account to run the function with, stored in CI/CD env variables"
}

variable "environment_variables" {
  type        = map(string)
  description = "A set of key/value environment variable pairs to assign to the function"
  default     = {}
}

variable "labels" {
  type        = map(string)
  description = "A set of key/value label pairs to assign to the function"
  default     = {}
}

variable "schedule" {
  type        = string
  description = "Describes the schedule on which the job will be executed"
  default     = "*/30 * * * *"
}

variable "schedule_time_zone" {
  type        = string
  description = "Specifies the time zone to be used in interpreting schedule. The value of this field must be a time zone name from the tz database"
  default     = "Europe/Prague"
}

variable "schedule_retry_config" {
  type = object({
    retry_count          = number,
    max_retry_duration   = string,
    min_backoff_duration = string,
    max_backoff_duration = string,
    max_doublings        = number,
  })
  description = "By default, if a job does not complete successfully, meaning that an acknowledgement is not received from the handler, then it will be retried with exponential backoff"
  default = {
    retry_count          = 0,
    max_retry_duration   = "0s",
    min_backoff_duration = "5s",
    max_backoff_duration = "3600s",
    max_doublings        = 5
  }
}

variable "schedule_payload" {
  type        = string
  description = "Payload for Cloud Scheduler"
  default     = "{}"
}

variable "invokers" {
  type        = list(string)
  description = "List of function invokers (i.e. allUsers if you want to Allow unauthenticated)"
  default     = []
}

variable "vpc_access_connector" {
  type        = string
  description = "Enable access to shared VPC 'projects/<host-project>/locations/<region>/connectors/<connector>'"
  default     = null
}

variable "gitlab_project_path" {
  type        = string
  description = "A GitLab path to the project (CI_PROJECT_PATH)"
}

variable "sls_project_env" {
  type        = string
  description = "Project's SLS environment."
}

variable "vault_sync_enabled" {
  type        = bool
  description = "Set this value to true if you want to sync secrets from Vault."
}

variable "vault_sync_type" {
  type        = string
  description = "Select sync type for Vault (env or secret_manager)."
  default     = "secret_manager"

  validation {
    condition     = can(regex("^(secret_manager|env)$", var.vault_sync_type))
    error_message = "Possible values are: secret_manager or env."
  }
}

locals {
  // Constants
  TRIGGER_TYPE_HTTP      = "http"
  TRIGGER_TYPE_TOPIC     = "topic"
  TRIGGER_TYPE_SCHEDULER = "scheduler"
  TRIGGER_TYPE_BUCKET    = "bucket"

  VAULT_SYNC_TYPE_SECRET_MANAGER = "secret_manager"
  VAULT_SYNC_TYPE_ENV            = "env"

  source_dir        = var.source_dir != "" ? "${path.root}/${var.source_dir}" : path.root
  function_name     = var.function_name != "" ? var.function_name : "${var.sls_project_name}-${var.entry_point}"
  region_app_engine = var.region_app_engine != "" ? var.region_app_engine : var.region
  labels = merge({
    deployment-tool = "terraform"
    gitlab-path     = replace(var.gitlab_project_path, "/", "_")
    vault-sync      = var.vault_sync_enabled ? var.vault_sync_type : ""
    alert-channel   = local.alerts_enabled ? replace(var.alert_channel, "#", "") : ""
  }, var.labels)
  vault_path = "kw/secret/${var.gitlab_project_path}/runtime/${var.sls_project_env}"

  is_vault_sync_env            = var.vault_sync_enabled && var.vault_sync_type == local.VAULT_SYNC_TYPE_ENV
  is_vault_sync_secret_manager = var.vault_sync_enabled && var.vault_sync_type == local.VAULT_SYNC_TYPE_SECRET_MANAGER

  secret_id = local.function_name

  default_environment_variables = {
    GCP_PROJECT_ID : var.project,
    GCP_SECRET_ID : local.secret_id
  }

  environment_variables = local.is_vault_sync_env ? merge(local.default_environment_variables, var.environment_variables, data.vault_generic_secret.secret[0].data) : merge(local.default_environment_variables, var.environment_variables)
}
