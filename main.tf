terraform {
  required_version = ">=1.5"
  required_providers {
    fastly = {
      source  = "fastly/fastly"
      version = ">= 7.1.0"
    }
  }
}

provider "fastly" {
  api_key = var.fastly_api_token
}

locals {
  asset_path = "${path.cwd}/assets/${var.compute_asset_name}"
  asset_hash = try(filebase64sha512(local.asset_path), "")
  config_store_name       = "${var.config_store_prefix}${var.service_id}"
  secret_store_name       = "${var.secret_store_prefix}${var.service_id}"
  kv_store_name           = "${var.kv_store_prefix}${var.service_id}"
  kv_store_plugin_enabled = var.kv_store_enabled ? var.kv_store_save_plugin_enabled : "false"
}

module "compute_asset" {
  count                        = var.download_asset ? 1 : 0
  source                       = "./modules/download_asset"
  asset_version                = var.asset_version
  compute_asset_name           = var.compute_asset_name
  repository_name              = var.asset_repository_name
  repository_organization_name = var.asset_repository_organization_name
  asset_download_path          = local.asset_path
}

resource "fastly_kvstore" "integration_kv_store" {
  count = var.kv_store_enabled ? 1 : 0
  name  = local.kv_store_name
}

resource "fastly_configstore" "integration_config_store" {
  name = local.config_store_name
}

resource "fastly_configstore_entries" "integration_config_store_entries" {
  store_id = fastly_configstore.integration_config_store.id
  manage_entries = var.manage_fastly_config_store_entries
  entries = {
    AGENT_SCRIPT_DOWNLOAD_PATH      = var.agent_script_download_path
    GET_RESULT_PATH                 = var.get_result_path
    SAVE_TO_KV_STORE_PLUGIN_ENABLED = local.kv_store_plugin_enabled
  }
}

resource "fastly_secretstore" "integration_secret_store" {
  name = local.secret_store_name
}

resource "fastly_service_compute" "fingerprint_integration" {
  name = var.integration_name

  domain {
    name = var.integration_domain
  }

  package {
    filename         = local.asset_path
    source_code_hash = local.asset_hash
  }

  backend {
    address           = var.fpjs_backend_url
    name              = var.fpjs_backend_url
    override_host     = var.fpjs_backend_url
    prefer_ipv6       = false
    use_ssl           = true
    ssl_cert_hostname = var.fpjs_backend_url
    ssl_sni_hostname  = var.fpjs_backend_url
    port              = 443
  }

  backend {
    address           = "eu.${var.fpjs_backend_url}"
    name              = "eu.${var.fpjs_backend_url}"
    override_host     = "eu.${var.fpjs_backend_url}"
    prefer_ipv6       = false
    use_ssl           = true
    ssl_cert_hostname = "eu.${var.fpjs_backend_url}"
    ssl_sni_hostname  = "eu.${var.fpjs_backend_url}"
    port              = 443
  }

  backend {
    address           = "ap.${var.fpjs_backend_url}"
    name              = "ap.${var.fpjs_backend_url}"
    override_host     = "ap.${var.fpjs_backend_url}"
    prefer_ipv6       = false
    use_ssl           = true
    ssl_cert_hostname = "ap.${var.fpjs_backend_url}"
    ssl_sni_hostname  = "ap.${var.fpjs_backend_url}"
    port              = 443
  }

  backend {
    address           = var.fpjs_cdn_url
    name              = var.fpjs_cdn_url
    override_host     = var.fpjs_cdn_url
    prefer_ipv6       = false
    use_ssl           = true
    ssl_cert_hostname = var.fpjs_cdn_url
    ssl_sni_hostname  = var.fpjs_cdn_url
    port              = 443
  }

  resource_link {
    name        = local.config_store_name
    resource_id = fastly_configstore.integration_config_store.id
  }

  resource_link {
    name        = local.secret_store_name
    resource_id = fastly_secretstore.integration_secret_store.id
  }

  dynamic "resource_link" {
    for_each = var.kv_store_enabled ? [0] : []
    content {
      name        = local.kv_store_name
      resource_id = fastly_kvstore.integration_kv_store[0].id
    }
  }

  force_destroy = true

  depends_on = [
    fastly_configstore.integration_config_store, fastly_configstore_entries.integration_config_store_entries,
    fastly_secretstore.integration_secret_store
  ]
}

