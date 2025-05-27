terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.2.2"
    }
    get = {
      source  = "cludden/get"
      version = "0.1.2"
    }
  }
}

data "github_release" "selected" {
  repository  = var.repository_name
  owner       = var.repository_organization_name
  retrieve_by = var.asset_version_min
}

locals {
  compute_download_url = [
    for asset in data.github_release.selected.assets :
    asset.browser_download_url
    if asset.name == var.compute_asset_name
  ][
  0
  ]
}

resource "get_artifact" "download_asset" {
  url     = local.compute_download_url
  dest    = "${path.cwd}/assets/${var.compute_asset_name}"
  mode    = "file"
  archive = false
  workdir = abspath(path.root)
}

data "local_file" "compute_asset" {
  filename = "${path.cwd}/assets/${var.compute_asset_name}"
  depends_on = [get_artifact.download_asset]
}

output "filename" {
  value = data.local_file.compute_asset.filename
}

output "full_path" {
  value = abspath(data.local_file.compute_asset.filename)
}
