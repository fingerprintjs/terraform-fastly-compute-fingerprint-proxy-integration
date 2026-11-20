variable "repository_organization_name" {
  type    = string
  default = "fingerprintjs"
}

variable "repository_name" {
  type    = string
  default = "fastly-compute-proxy"
}

variable "asset_version" {
  type     = string
  default  = "latest"
  nullable = false
}

variable "compute_asset_name" {
  type    = string
  default = "fingerprint-fastly-compute-proxy-integration.tar.gz"
}

variable "service_id" {
  type        = string
  description = "ID of the Fastly Compute service the package is for. A new service_id downloads the package again, so the new service gets it even when the file is missing on this machine"
}
