variable "integration_domain" {
  type = string
  nullable = false
}

variable "integration_name" {
  type = string
  default = "fingerprint-fastly-compute-proxy-integration"
  nullable = false
  validation {
    condition     = can(regex("^([a-zA-Z0-9\\_\\-])+$", var.integration_name))
    error_message = "value should only consist of alphanumeric values and dashes"
  }
}

variable "config_store_prefix" {
  type = string
  default = "Fingerprint_Compute_Config_Store_"
  nullable = false
  validation {
    condition     = can(regex("^([a-zA-Z0-9\\_])+$", var.config_store_prefix))
    error_message = "value should only consist of alphanumeric values and underscores"
  }
}

variable "manage_fastly_config_store_entries" {
  type = bool
  default = false
  nullable = false
  description = "Manage Fastly Config Store entries via terraform, see link: https://registry.terraform.io/providers/fastly/fastly/latest/docs/resources/configstore_entries#manage_entries-1"
}

variable "secret_store_prefix" {
  type = string
  default = "Fingerprint_Compute_Secret_Store_"
  nullable = false
  validation {
    condition     = can(regex("^([a-zA-Z0-9\\_])+$", var.secret_store_prefix))
    error_message = "value should only consist of alphanumeric values and underscores"
  }
}

variable "fastly_api_token" {
  type = string
  nullable = false
}

variable "agent_script_download_path" {
  type = string
  default = null
  nullable = true
  validation {
    condition     = var.agent_script_download_path == null || can(regex("^([a-zA-Z0-9\\-])+$", var.agent_script_download_path))
    error_message = "value should only consist of alphanumeric values and dashes"
  }
}

variable "get_result_path" {
  type = string
  default = null
  nullable = true
  validation {
    condition     = var.get_result_path == null || can(regex("^([a-zA-Z0-9\\-])+$", var.get_result_path))
    error_message = "value should only consist of alphanumeric values and dashes"
  }
}

variable "asset_repository_organization_name" {
  type    = string
  default = "fingerprintjs"
}

variable "asset_repository_name" {
  type    = string
  default = "fastly-compute-proxy"
}

variable "asset_version" {
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

variable "kv_store_enabled" {
  type        = bool
  default     = false
  description = "Deprecated: No-op. KV store plugin system has been removed in v4."
}

variable "kv_store_prefix" {
  type        = string
  default     = "Fingerprint_Results_"
  description = "Deprecated: No-op. KV store plugin system has been removed in v4."
}

