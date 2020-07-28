data "archive_file" "source_archive" {
  type        = "zip"
  source_dir  = path.root
  excludes    = [
    ".coafile",
    ".git",
    ".gitignore",
    ".gitlab-ci.yml",
    ".idea",
    ".pre-commit-config.yaml",
    ".pylintrc",
    ".terraform",
    ".terraform.tfstate.lock.info",
    ".terraform-version",
    "credentials.json",
    "functions.tf",
    "Makefile",
    "outputs.tf",
    "permissions.tf",
    "providers.tf",
    "schedulers.tf",
    "services.tf",
    "source.tf",
    "source.zip",
    "terraform.tfvars",
    "terraform.tfstate",
    "tmp",
    "variables.tf",
  ]
  output_path = "tmp/source.zip"
}

resource "google_storage_bucket_object" "source_object" {
  name   = "source-${data.archive_file.source_archive.output_md5}.zip"
  bucket = var.cf_src_bucket
  source = data.archive_file.source_archive.output_path
}