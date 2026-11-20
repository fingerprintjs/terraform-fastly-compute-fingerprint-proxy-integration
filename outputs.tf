output "service_id" {
  description = "ID of the Fastly Compute service"
  value       = fastly_service_compute.fingerprint_integration.id
}

output "service_name" {
  description = "Name of the Fastly Compute service"
  value       = fastly_service_compute.fingerprint_integration.name
}

output "active_version" {
  description = "Active version of the Fastly Compute service"
  value       = fastly_service_compute.fingerprint_integration.active_version
}

output "package_version" {
  description = "Release tag of the downloaded Compute package, for example v0.4.2. Null when custom_package is set"
  value       = var.custom_package == null ? module.compute_asset[0].version : null
}

output "secret_store_id" {
  description = "ID of the Fastly Secret Store. Add the PROXY_SECRET item to it"
  value       = fastly_secretstore.integration_secret_store.id
}

output "secret_store_name" {
  description = "Name of the Fastly Secret Store. Add the PROXY_SECRET item to it"
  value       = fastly_secretstore.integration_secret_store.name
}

output "config_store_id" {
  description = "ID of the Fastly Config Store. Null when agent_script_download_path and get_result_path are not set"
  value       = one(fastly_configstore.integration_config_store[*].id)
}

output "integration_domain" {
  description = "Domain of the integration. Read from the service, so resources that use it wait for the service, for example a TLS subscription"
  value       = one(fastly_service_compute.fingerprint_integration.domain).name
}

output "integration_url" {
  description = "Integration URL for the JavaScript agent `endpoints` option"
  value       = "https://${var.integration_domain}/"
}
