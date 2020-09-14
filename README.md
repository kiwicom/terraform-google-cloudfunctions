# terraform-google-cloudfunctions

## Prerequisites

* GCP Project

## Usage

### http

```hcl-terraform
module "your_application_http" {
  source           = "kiwicom/cloudfunctions/google"
  sls_project_name = var.sls_project_name
  cf_src_bucket    = var.cf_src_bucket
  entry_point      = "http_handler"
  project          = var.google_project

  trigger_type = "http"

  region              = "europe-west1"
  runtime             = "python37"
  available_memory_mb = 256
  timeout             = 60

  service_account_email = var.service_account_email
  environment_variables = {}
  
  vault_sync_enabled = true

  invokers = [
    "allUsers",
  ]

  labels = {
    app = "your-application"
  }
}
```

### scheduler

```hcl-terraform
module "your_application_scheduler" {
  source           = "kiwicom/cloudfunctions/google"
  sls_project_name = var.sls_project_name
  cf_src_bucket    = var.cf_src_bucket
  entry_point      = "scheduler_handler"
  project          = var.google_project

  trigger_type = "scheduler"

  region              = "europe-west1"
  runtime             = "python37"
  available_memory_mb = 256
  timeout             = 60

  service_account_email = var.service_account_email
  environment_variables = {}
  
  vault_sync_enabled = true

  schedule              = "50 */4 * * *"
  schedule_time_zone    = "Europe/Prague"
  schedule_payload      = "start"
  schedule_retry_config = {
    retry_count          = 0,
    max_retry_duration   = "0s",
    min_backoff_duration = "5s",
    max_backoff_duration = "3600s",
    max_doublings        = 16
  }

  labels = {
    app = "your-application"
  }
}
```

### topic

```hcl-terraform
module "your_applicaton_topic" {
  source           = "kiwicom/cloudfunctions/google"
  sls_project_name = var.sls_project_name
  cf_src_bucket    = var.cf_src_bucket
  entry_point      = "topic_handler"
  project          = var.google_project

  trigger_type = "topic"

  region              = "europe-west1"
  runtime             = "python37"
  available_memory_mb = 256
  timeout             = 60

  service_account_email = var.service_account_email
  environment_variables = {}
  
  vault_sync_enabled = true

  trigger_event_type     = "google.pubsub.topic.publish"
  trigger_event_resource = "topic-id"
}
```

### bucket

```hcl-terraform
module "your_applicaton_bucket" {
  source           = "kiwicom/cloudfunctions/google"
  sls_project_name = var.sls_project_name
  cf_src_bucket    = var.cf_src_bucket
  entry_point      = "bucket_handler"
  project          = var.google_project

  trigger_type = "bucket"

  region              = "europe-west1"
  runtime             = "python37"
  available_memory_mb = 256
  timeout             = 60

  service_account_email = var.service_account_email
  environment_variables = {}

  vault_sync_enabled = true

  trigger_event_type     = "google.storage.object.finalize"
  trigger_event_resource = "bucket-id"
}
```

## Vault sync

Module can sync secrets from Vault. It can sync either to Google Secret Manager or environment variables (not recommended).

To enable sync just add `vault_sync_enabled = true` to module definition.

You can select sync type with `vault_sync_type` variable. It can be set to `secret_manager` or `env`.

## Variables

In order to check which variables are customizable, check `variables.tf`.
