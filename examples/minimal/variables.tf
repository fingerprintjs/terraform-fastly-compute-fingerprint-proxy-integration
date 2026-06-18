variable "agent_script_download_path" {
  description = "The Fingerprint agent download will be proxied through this path"
  type = string
  nullable = true
  default = null
}

variable "get_result_path" {
  description = "The Fingerprint identification / get-result requests will be proxied through this path"
  type = string
  nullable = true
  default = null
}

variable "integration_domain" {
  description = "Domain used for your proxy integration"
  type = string
}

variable "integration_name" {
  description = "Service name used for your proxy integration"
  type = string
  default = "fingerprint-fastly-compute-proxy-integration"
  nullable = false
}

variable "service_id" {
  description = "ID of your empty Fastly Compute service"
  type = string
}

variable "fastly_api_token" {
  type = string
}

variable "compute_asset_name" {
  type    = string
  default = "fingerprint-fastly-compute-proxy-integration.tar.gz"
}

variable "download_asset" {
  type = bool
  default = true
}

variable "region" {
  type     = string
  default  = null
  nullable = true
}
