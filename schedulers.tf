resource "google_pubsub_topic" "scheduler" {
  count = var.trigger_scheduler ? 1 : 0
  name  = local.function_name
}

resource "google_cloud_scheduler_job" "scheduler" {
  count       = var.trigger_scheduler ? 1 : 0
  name        = local.function_name
  description = "Triggers ${google_cloudfunctions_function.function_pubsub[0].name} function through ${google_pubsub_topic.scheduler[0].name} topic"
  schedule    = var.schedule
  time_zone   = var.schedule_time_zone
  region      = local.region_app_engine

  pubsub_target {
    topic_name = google_pubsub_topic.scheduler[0].id
    data       = base64encode("Ping")
  }
}
