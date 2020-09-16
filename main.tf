resource "google_cloudfunctions_function" "function_http" {
  count   = var.trigger_type == local.TRIGGER_TYPE_HTTP ? 1 : 0
  name    = local.function_name
  project = var.project

  entry_point  = var.entry_point
  trigger_http = true

  runtime             = var.runtime
  region              = var.region
  available_memory_mb = var.available_memory_mb
  timeout             = var.timeout
  max_instances       = var.max_instances

  service_account_email = var.service_account_email
  environment_variables = local.environment_variables
  labels                = local.labels

  source_archive_bucket = var.cf_src_bucket
  source_archive_object = google_storage_bucket_object.source_object.name

  vpc_connector = var.vpc_access_connector
}

resource "google_cloudfunctions_function" "function_event" {
  count   = var.trigger_type != local.TRIGGER_TYPE_HTTP ? 1 : 0
  name    = local.function_name
  project = var.project

  entry_point = var.entry_point

  runtime             = var.runtime
  region              = var.region
  available_memory_mb = var.available_memory_mb
  timeout             = var.timeout
  max_instances       = var.max_instances

  service_account_email = var.service_account_email
  environment_variables = local.environment_variables
  labels                = local.labels

  source_archive_bucket = var.cf_src_bucket
  source_archive_object = google_storage_bucket_object.source_object.name

  vpc_connector = var.vpc_access_connector

  event_trigger {
    event_type = var.trigger_type == local.TRIGGER_TYPE_SCHEDULER ? "google.pubsub.topic.publish" : var.trigger_event_type
    resource   = var.trigger_type == local.TRIGGER_TYPE_SCHEDULER ? google_pubsub_topic.scheduler[0].id : var.trigger_event_resource
  }
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  for_each       = var.trigger_type == local.TRIGGER_TYPE_HTTP ? toset(var.invokers) : toset([])
  project        = google_cloudfunctions_function.function_http[0].project
  region         = google_cloudfunctions_function.function_http[0].region
  cloud_function = google_cloudfunctions_function.function_http[0].name
  role           = "roles/cloudfunctions.invoker"
  member         = each.value
}
