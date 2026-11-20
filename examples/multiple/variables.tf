variable "integrations" {
  description = "Integrations to deploy. The key is used in the Fastly service name"
  type = map(object({
    service_id         = string
    integration_domain = string
  }))
}

variable "region" {
  description = "Region for the Fingerprint API: us, eu, or ap"
  type        = string
  default     = "us"
}
