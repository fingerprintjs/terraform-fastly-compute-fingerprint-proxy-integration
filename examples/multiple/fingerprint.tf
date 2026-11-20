# Each integration needs its own empty Compute service, imported here
import {
  for_each = var.integrations
  to       = module.fingerprint_fastly_compute_integration[each.key].fastly_service_compute.fingerprint_integration
  id       = each.value.service_id
}

module "fingerprint_fastly_compute_integration" {
  source   = "../.."
  for_each = var.integrations

  integration_name   = "fingerprint-fastly-compute-${each.key}"
  service_id         = each.value.service_id
  integration_domain = each.value.integration_domain
  region             = var.region
}

output "integration_urls" {
  description = "Integration URL of each integration, for the JavaScript agent `endpoints` option"
  value       = { for name, integration in module.fingerprint_fastly_compute_integration : name => integration.integration_url }
}

output "secret_store_names" {
  description = "Secret Store of each integration. Add the PROXY_SECRET item to each of them"
  value       = { for name, integration in module.fingerprint_fastly_compute_integration : name => integration.secret_store_name }
}
