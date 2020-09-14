data "archive_file" "source_archive" {
  type       = "zip"
  source_dir = local.source_dir
  excludes = [
    ".cache",
    ".git",
    ".gitignore",
    ".gitlab-ci.yml",
    ".idea",
    ".pre-commit-config.yaml",
    ".terraform",
    ".terraform.tfstate.lock.info",
    ".terraform-version",
    "credentials.json",
    "functions.tf",
    "Makefile",
    "outputs.tf",
    "providers.tf",
    "source.zip",
    "storage.tf",
    "terraform.tfvars",
    "terraform.tfstate",
    "tmp",
    "variables.tf",
  ]
  output_path = "tmp/source.zip"
}

resource "google_storage_bucket_object" "source_object" {
  name   = "source-${local.function_name}-${data.archive_file.source_archive.output_md5}.zip"
  bucket = var.cf_src_bucket
  source = data.archive_file.source_archive.output_path
}
