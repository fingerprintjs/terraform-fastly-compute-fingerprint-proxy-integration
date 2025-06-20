terraform {
  required_providers {
    fastly = {
      source  = "fastly/fastly"
      version = ">= 7.0.0"
    }
  }
}

provider "fastly" {
  api_key = var.fastly_api_key
}

module "compute_asset" {
  count                        = var.download_asset ? 1 : 0
  source                       = "./modules/download_asset"
  asset_version_min            = var.asset_version_min
  compute_asset_name           = var.compute_asset_name
  repository_name              = var.repository_name
  repository_organization_name = var.repository_organization_name
}

locals {
  asset_path = "${path.cwd}/assets/${var.compute_asset_name}"
}

locals {
  asset_hash = try(filebase64sha512(local.asset_path), "")
  config_store_name       = "${var.config_store_prefix}${var.service_id}"
  secret_store_name       = "${var.secret_store_prefix}${var.service_id}"
  kv_store_name           = "${var.kv_store_prefix}${var.service_id}"
  kv_store_plugin_enabled = var.kv_store_enabled ? var.kv_store_save_plugin_enabled : "false"
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
    address       = var.fpjs_backend_url
    name          = var.fpjs_backend_url
    override_host = var.fpjs_backend_url
  }

  backend {
    address       = "eu.${var.fpjs_backend_url}"
    name          = "eu.${var.fpjs_backend_url}"
    override_host = "eu.${var.fpjs_backend_url}"
  }

  backend {
    address       = "ap.${var.fpjs_backend_url}"
    name          = "ap.${var.fpjs_backend_url}"
    override_host = "ap.${var.fpjs_backend_url}"
  }

  backend {
    address       = var.fpjs_cdn_url
    name          = var.fpjs_cdn_url
    override_host = var.fpjs_cdn_url
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

  lifecycle {
    ignore_changes = [
      package[0].source_code_hash
    ]
  }

  depends_on = [
    fastly_configstore.integration_config_store, fastly_configstore_entries.integration_config_store_entries,
    fastly_secretstore.integration_secret_store
  ]
}

