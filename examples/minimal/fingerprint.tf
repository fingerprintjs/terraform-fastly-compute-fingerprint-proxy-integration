module "fingerprint_fastly_compute_integration" {
  source = "../.."
  agent_script_download_path = var.agent_script_download_path
  get_result_path = var.get_result_path
  integration_domain = var.integration_domain
  service_id = var.service_id
  fastly_api_token = var.fastly_api_token
  integration_name = var.integration_name
  download_asset = var.download_asset
  compute_asset_name = var.compute_asset_name
}
