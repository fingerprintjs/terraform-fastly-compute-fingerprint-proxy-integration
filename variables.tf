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
  sensitive = true
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

variable "service_id" {
  type = string
}

variable "download_asset" {
  type = bool
  default = true
}

variable "fpjs_backend_url" {
  type = string
  default = "api.fpjs.io"
}

variable "fpjs_cdn_url" {
  type = string
  default = "fpcdn.io"
}

variable "kv_store_enabled" {
  type = bool
  default = false
}

variable "kv_store_save_plugin_enabled" {
  type = string
  default = "false"
  validation {
    condition = var.kv_store_save_plugin_enabled == "true" || var.kv_store_save_plugin_enabled == "false"
    error_message = "The kv_store_save_plugin_enabled variable should either string `true` or string `false`"
  }
}

variable "kv_store_prefix" {
  type = string
  default = "Fingerprint_Results_"
}
