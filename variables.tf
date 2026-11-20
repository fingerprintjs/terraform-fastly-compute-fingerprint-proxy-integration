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

variable "force_destroy" {
  type        = bool
  default     = true
  nullable    = false
  description = "Let Terraform delete the Fastly service while it is active, for example on terraform destroy. Set to false to protect the service from being deleted"
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
  type        = string
  default     = "fingerprintjs"
  nullable    = false
  description = "GitHub organization of the repository to download the Compute package from"
  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+$", var.asset_repository_organization_name))
    error_message = "value should only consist of alphanumeric values, dots, dashes and underscores"
  }
}

variable "asset_repository_name" {
  type        = string
  default     = "fastly-compute-proxy"
  nullable    = false
  description = "GitHub repository to download the Compute package from"
  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+$", var.asset_repository_name))
    error_message = "value should only consist of alphanumeric values, dots, dashes and underscores"
  }
}

variable "asset_version" {
  type        = string
  default     = "latest"
  nullable    = false
  description = "\"latest\" for the newest v0.4.x release of the Compute package, or a release tag to pin, for example \"v0.4.2\""
}

variable "compute_asset_name" {
  type        = string
  default     = "fingerprint-fastly-compute-proxy-integration.tar.gz"
  nullable    = false
  description = "Name of the package asset in the GitHub release"
  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+$", var.compute_asset_name))
    error_message = "value should only consist of alphanumeric values, dots, dashes and underscores"
  }
}

variable "custom_package" {
  type = object({
    filename = string
  })
  default     = null
  description = "Your own Compute package, for example { filename = \"custom.tar.gz\" }. When set, the module doesn't download the official package. An object, so the module knows at plan time whether to download even when filename is only known after apply."
}

variable "service_id" {
  type = string
}

variable "fpjs_backend_url" {
  type = string
  default = "api.fpjs.io"
}

variable "region" {
  type     = string
  default  = null
  nullable = true
  description = "Region for the Fingerprint API. One of: us, eu, ap. When set, a single 'fingerprint' backend is created for that region. When null, the legacy regional backends are used."
  validation {
    condition     = var.region == null || contains(["us", "eu", "ap"], var.region)
    error_message = "region must be one of: us, eu, ap"
  }
}

