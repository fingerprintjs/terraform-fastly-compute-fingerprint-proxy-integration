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
  ][0]

  compute_local_path = "${path.module}/assets/${var.compute_asset_name}"
}

output "download_url" {
  value = local.compute_download_url
}

output "local_path" {
  value = local.compute_local_path
}

data "external" "compute_download" {
  program = ["bash", "${path.module}/scripts/download_asset.sh"]
  query = {
    url  = local.compute_download_url
    path = local.compute_local_path
  }
}


data "local_file" "compute_asset" {
  filename    = local.compute_local_path
  depends_on  = [data.external.compute_download]
}

output "compute_package_hash" {
  value = filebase64sha512(local.compute_local_path)
  depends_on = [data.local_file.compute_asset]
}
