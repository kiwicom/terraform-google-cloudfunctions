output "function_http_url" {
  value = join(" ", google_cloudfunctions_function.function_http.*.https_trigger_url)
}

output "scheduler_topic_name" {
  value = join(" ", google_pubsub_topic.scheduler.*.name)
}
