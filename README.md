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

  trigger_event_type     = "google.storage.object.finalize"
  trigger_event_resource = "bucket-id"
}
```

## Variables

In order to check which variables are customizable, check `variables.tf`.
