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
  config_store_name    = "${var.config_store_prefix}${var.service_id}"
  secret_store_name    = "${var.secret_store_prefix}${var.service_id}"
  fingerprint_backend_address = var.region == null ? null : {
    us = var.fpjs_backend_url
    eu = "eu.${var.fpjs_backend_url}"
    ap = "ap.${var.fpjs_backend_url}"
  }[var.region]
  config_store_entries = {
    for key, value in {
      AGENT_SCRIPT_DOWNLOAD_PATH = var.agent_script_download_path
      GET_RESULT_PATH            = var.get_result_path
    } : key => value if value != null
  }
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

resource "fastly_configstore" "integration_config_store" {
  count = length(local.config_store_entries) > 0 ? 1 : 0
  name  = local.config_store_name
}

resource "fastly_configstore_entries" "integration_config_store_entries" {
  count          = length(local.config_store_entries) > 0 ? 1 : 0
  store_id       = fastly_configstore.integration_config_store[0].id
  manage_entries = var.manage_fastly_config_store_entries
  entries        = local.config_store_entries
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

  dynamic "backend" {
    for_each = var.region != null ? [local.fingerprint_backend_address] : []
    content {
      address           = backend.value
      name              = "fingerprint"
      override_host     = backend.value
      prefer_ipv6       = false
      use_ssl           = true
      ssl_cert_hostname = backend.value
      ssl_sni_hostname  = backend.value
      port              = 443
    }
  }

  dynamic "backend" {
    for_each = var.region == null ? [
      var.fpjs_backend_url,
      "eu.${var.fpjs_backend_url}",
      "ap.${var.fpjs_backend_url}",
    ] : []
    content {
      address           = backend.value
      name              = backend.value
      override_host     = backend.value
      prefer_ipv6       = false
      use_ssl           = true
      ssl_cert_hostname = backend.value
      ssl_sni_hostname  = backend.value
      port              = 443
    }
  }

  dynamic "resource_link" {
    for_each = length(local.config_store_entries) > 0 ? [0] : []
    content {
      name        = local.config_store_name
      resource_id = fastly_configstore.integration_config_store[0].id
    }
  }

  resource_link {
    name        = local.secret_store_name
    resource_id = fastly_secretstore.integration_secret_store.id
  }

  force_destroy = true

  depends_on = [
    fastly_secretstore.integration_secret_store,
    fastly_configstore_entries.integration_config_store_entries
  ]
}

check "region_not_set" {
  assert {
    condition     = var.region != null
    error_message = "The region variable is not set. Legacy regional backends (us/eu/ap) are deprecated and will be removed in a future version. Set region to one of: us, eu, ap."
  }
}
