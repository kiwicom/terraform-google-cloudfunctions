// TODO: move this to its own repository
// TODO: update cookiecutter-sls accordingly, code etc
// TODO: migrate projects
// TODO: Update tf-sls-projects, give permissions for pub sub
// TODO: update gitlab ci templates readme
// TODO: vault setup

resource "google_cloudfunctions_function" "function_http" {
  count   = var.trigger_http ? 1 : 0
  name    = "${var.sls_project_name}-${var.entry_point}"
  project = var.project

  entry_point  = var.entry_point
  trigger_http = true

  runtime             = var.runtime
  region              = var.region
  available_memory_mb = var.available_memory_mb
  timeout             = var.timeout

  service_account_email = var.service_account_email
  environment_variables = var.environment_variables

  source_archive_bucket = var.cf_src_bucket
  source_archive_object = google_storage_bucket_object.source_object.name
}

resource "google_cloudfunctions_function" "function_pubsub" {
  count   = var.trigger_scheduler ? 1 : 0
  name    = "${var.sls_project_name}-${var.entry_point}"
  project = var.project

  entry_point = var.entry_point

  runtime             = var.runtime
  region              = var.region
  available_memory_mb = var.available_memory_mb
  timeout             = var.timeout

  service_account_email = var.service_account_email
  environment_variables = var.environment_variables

  source_archive_bucket = var.cf_src_bucket
  source_archive_object = google_storage_bucket_object.source_object.name

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.scheduler[0].name
  }
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  for_each       = var.trigger_http ? var.invokers : toset([])
  project        = google_cloudfunctions_function.function_http[0].project
  region         = google_cloudfunctions_function.function_http[0].region
  cloud_function = google_cloudfunctions_function.function_http[0].name
  role           = "roles/cloudfunctions.invoker"
  member         = each.value
}
