// Outputs

output "function_http_url" {
  value = google_cloudfunctions_function.function_http.*.https_trigger_url
}
