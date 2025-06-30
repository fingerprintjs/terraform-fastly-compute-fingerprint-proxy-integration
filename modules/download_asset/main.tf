terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.2.2"
    }
  }
}

data "github_release" "selected" {
  repository  = var.repository_name
  owner       = var.repository_organization_name
  retrieve_by = var.asset_version
}

locals {
  compute_download_url = [
    for asset in data.github_release.selected.assets :
    asset.browser_download_url
    if asset.name == var.compute_asset_name
  ][0]

  compute_asset_path = "${path.cwd}/assets/${var.compute_asset_name}"
}

resource "null_resource" "download_asset" {
  provisioner "local-exec" {
    command = <<EOT
      mkdir -p "${path.cwd}/assets"
      curl -L -o "${local.compute_asset_path}" "${local.compute_download_url}"
    EOT
  }
}

data "local_file" "compute_asset" {
  filename   = local.compute_asset_path
  depends_on = [null_resource.download_asset]
}
