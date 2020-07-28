variable "sls_project_name" {
  type        = string
  description = "Project name composed of {project_name}-{project_env}, stored in CI/CD env variables"
}

variable "cf_src_bucket" {
  type        = string
  description = "Source archive bucket for Cloud Functions, stored in CI/CD env variables"
}

variable "entry_point" {
  type        = string
  description = "Name of the function that will be executed when the Google Cloud Function is triggered"
}

variable "trigger_http" {
  type        = bool
  description = "If true, function will be assigned an endpoint"
  default     = false
}

variable "trigger_scheduler" {
  type        = bool
  description = "If true, scheduler will be configured and function will be triggered by it"
  default     = false
}

variable "project" {
  type        = string
  description = "Google Cloud Platform project id, stored in CI/CD env variables"
}

variable "region" {
  type        = string
  default     = "europe-west1"
  description = "Google Cloud Platform default region"
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

variable "service_account_email" {
  type        = string
  description = "Self-provided service account to run the function with, stored in CI/CD env variables"
}

variable "environment_variables" {
  type        = object({})
  description = "A set of key/value environment variable pairs to assign to the function"
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

variable "invokers" {
  type        = set(string)
  description = "Set of function invokers, defaults to allUsers"
  default     = [
    "allUsers"
  ]
}