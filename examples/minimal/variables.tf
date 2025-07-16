variable "agent_script_download_path" {
  description = "The Fingerprint agent download will be proxied through this path"
  type = string
}

variable "get_result_path" {
  description = "The Fingerprint agent download will be proxied through this path"
  type = string
}

variable "integration_domain" {
  description = "Domain used for your proxy integration"
  type = string
}

variable "service_id" {
  description = "ID of your empty Fastly Compute service"
  type = string
}

variable "fastly_api_token" {
  type = string
}
