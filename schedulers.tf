resource "google_pubsub_topic" "scheduler" {
  count = var.trigger_type == local.TRIGGER_TYPE_SCHEDULER ? 1 : 0
  name  = local.function_name
}

resource "google_cloud_scheduler_job" "scheduler" {
  count       = var.trigger_type == local.TRIGGER_TYPE_SCHEDULER ? 1 : 0
  name        = local.function_name
  description = "Triggers ${google_cloudfunctions_function.function_event[0].name} function"
  schedule    = var.schedule
  time_zone   = var.schedule_time_zone
  region      = local.region_app_engine

  pubsub_target {
    attributes = {}
    topic_name = google_pubsub_topic.scheduler[0].id
    data       = base64encode(var.schedule_payload)
  }

  retry_config {
    retry_count          = var.schedule_retry_config.retry_count
    max_retry_duration   = var.schedule_retry_config.max_retry_duration
    min_backoff_duration = var.schedule_retry_config.min_backoff_duration
    max_backoff_duration = var.schedule_retry_config.max_backoff_duration
    max_doublings        = var.schedule_retry_config.max_doublings
  }
}
