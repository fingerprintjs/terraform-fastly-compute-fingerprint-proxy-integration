module "fingerprint_fastly_compute_integration" {
  source = "../.."
  agent_script_download_path = var.agent_script_download_path
  get_result_path = var.get_result_path
  integration_domain = var.integration_domain
  service_id = var.service_id
  fastly_api_token = var.fastly_api_token
}
