resource "google_pubsub_topic" "scheduler" {
  count = var.trigger_scheduler ? 1 : 0
  name  = "${var.sls_project_name}-${var.entry_point}"
}

resource "google_cloud_scheduler_job" "scheduler" {
  count       = var.trigger_scheduler ? 1 : 0
  name        = "${var.sls_project_name}-${var.entry_point}"
  description = "Triggers ${google_pubsub_topic.scheduler[0].name} topic"
  schedule    = var.schedule
  time_zone   = var.schedule_time_zone
  region      = var.region

  pubsub_target {
    topic_name = google_pubsub_topic.scheduler[0].id
    data       = base64encode("ping")
  }
}
