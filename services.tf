locals {
  services_to_enable = []
}

resource "google_project_service" "default_services" {
  count   = length(local.services_to_enable)
  project = var.project
  service = local.services_to_enable[count.index]
}
