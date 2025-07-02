variable "repository_organization_name" {
  type    = string
  default = "fingerprintjs"
}

variable "repository_name" {
  type    = string
  default = "fingerprint-pro-fastly-compute-proxy-integration"
}

variable "asset_version" {
  type    = string
  default = "latest"
}

variable "compute_asset_name" {
  type    = string
  default = "fingerprint-fastly-compute-proxy-integration.tar.gz"
}

variable "asset_download_path" {
  type = string
  nullable = false
}
