variable "integration_domain" {
  type = string
}

variable "main_host" {
  type = string
}

variable "test_domain_name" {
  type = string
  default = ""
}

variable "integration_name" {
  type = string
  default = "fingerprint-fastly-compute-proxy-integration"
}

variable "config_store_prefix" {
  type = string
  default = "Fingerprint_Compute_Config_Store_"
}

variable "secret_store_prefix" {
  type = string
  default = "Fingerprint_Compute_Secret_Store_"
}

variable "fastly_api_key" {
  type = string
}

variable "agent_script_download_path" {
  type = string
  default = "agent"
}

variable "get_result_path" {
  type = string
  default = "result"
}

variable "proxy_secret" {
  type = string
  default = "secret"
}

variable "repository_organization_name" {
  type    = string
  default = "fingerprintjs"
}

variable "repository_name" {
  type    = string
  default = "fingerprint-pro-fastly-compute-proxy-integration"
}

variable "asset_version_min" {
  type    = string
  default = "latest"
}

variable "compute_asset_name" {
  type    = string
  default = "fingerprint-fastly-compute-proxy-integration.tar.gz"
}

variable "activate_service" {
  type        = bool
  default     = false
}
