data "vault_generic_secret" "secret" {
  count = var.vault_sync_enabled ? 1 : 0
  path  = local.vault_path
}

resource "google_secret_manager_secret" "secret-json" {
  count     = local.is_vault_sync_secret_manager ? 1 : 0
  secret_id = var.sls_project_name
  labels = merge(local.labels, {
    vault_path = local.vault_path
  })
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "secret-version-json" {
  count       = local.is_vault_sync_secret_manager ? 1 : 0
  secret      = google_secret_manager_secret.secret-json[0].id
  secret_data = data.vault_generic_secret.secret[0].data_json
}
