locals {
  alerts_enabled = length(var.alert_slack_token) > 0 && var.sls_project_env == "prod"
}

variable "alert_slack_token" {
  description = "A Slack token that is used for alerting."
  default     = ""
}

variable "alert_channel" {
  description = "A Slack channel to send alerts to."
  default     = "#tmp-alerts-sls"
}

variable "alert_alignment_period" {
  description = "Alignment period for alerts."
  default     = "60s"
}

locals {
  slack_message = <<-EOT
    :warning: Function *${local.function_name}* has exited with either `crash`, `timeout`, `connection error` or `error` :exclamation:
    <https://console.cloud.google.com/functions/details/${var.region}/${local.function_name}?project=${var.project}&tab=logs| :cloud_functions: Logs>
    EOT
}

resource "google_monitoring_notification_channel" "slack" {
  count = local.alerts_enabled ? 1 : 0

  display_name = "${local.function_name} Slack Notification"
  type         = "slack"
  description  = "A slack notification channel for ${local.function_name}"
  enabled      = true
  labels = {
    "channel_name" = var.alert_channel
  }

  sensitive_labels {
    auth_token = var.alert_slack_token
  }
}

resource "google_logging_metric" "metric" {
  count = local.alerts_enabled ? 1 : 0

  name        = "${local.function_name}-metric"
  description = "${local.function_name} metric"

  filter = <<-EOT
    resource.type="cloud_function"
    resource.labels.function_name="${local.function_name}"
    severity="DEBUG"
    "finished with status: 'crash'"
    OR
    "finished with status: 'error'"
    OR
    "finished with status: 'timeout'"
    OR
    "finished with status: 'connection error'"
    EOT

  label_extractors = {
    "function_name" = "EXTRACT(resource.labels.function_name)"
  }
  metric_descriptor {
    display_name = "${local.function_name}-metric-descriptor"
    metric_kind  = "DELTA"
    value_type   = "INT64"
    labels {
      key        = "function_name"
      value_type = "STRING"
    }
  }
}

resource "google_monitoring_alert_policy" "alert_policy" {
  count = local.alerts_enabled ? 1 : 0

  display_name = "${local.function_name}-alert-policy"
  combiner     = "OR"
  notification_channels = [
    google_monitoring_notification_channel.slack[0].id
  ]
  conditions {
    display_name = "${local.function_name} alert policy condition"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.metric[0].id}\" resource.type=\"cloud_function\""
      duration   = "0s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = var.alert_alignment_period
        per_series_aligner = "ALIGN_DELTA"
      }
      trigger {
        count   = 1
        percent = 0
      }
    }
  }
  documentation {
    content   = local.slack_message
    mime_type = "text/markdown"
  }
}
