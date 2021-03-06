output "function_http_url" {
  value = join(" ", google_cloudfunctions_function.function_http.*.https_trigger_url)
}

output "scheduler_topic_id" {
  value = join(" ", google_pubsub_topic.scheduler.*.id)
}
