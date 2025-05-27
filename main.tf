terraform {
  required_providers {
    fastly = {
      source  = "fastly/fastly"
      version = ">= 7.0.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "2.0.1"
    }
  }
}

provider "fastly" {
  api_key = var.fastly_api_key
}

provider "restapi" {
  uri = "https://api.fastly.com"
  headers = {
    "Fastly-Key" = var.fastly_api_key
  }
  id_attribute = "id"
  write_returns_object = true
  copy_keys = ["id"]
}

module "compute_asset" {
  source = "./modules/download_asset"

  repository_name              = var.repository_name
  repository_organization_name = var.repository_organization_name
  asset_version_min            = var.asset_version_min
  compute_asset_name           = var.compute_asset_name
}

locals {
  real_hash = try(filebase64sha512(module.compute_asset.full_path), "")
}

resource "fastly_service_compute" "fingerprint_integration" {
  name = var.integration_name

  domain {
    name = var.integration_domain
  }

  dynamic "domain" {
    for_each = var.test_domain_name == "" ? [] : [0]
    content {
      name = "${var.test_domain_name}.edgecompute.app"
    }
  }

  package {
    filename         = module.compute_asset.full_path
    source_code_hash = local.real_hash
  }

  backend {
    address       = "api.fpjs.io"
    name          = "api.fpjs.io"
    override_host = "api.fpjs.io"
  }

  backend {
    address       = "eu.api.fpjs.io"
    name          = "eu.api.fpjs.io"
    override_host = "eu.api.fpjs.io"
  }

  backend {
    address       = "ap.api.fpjs.io"
    name          = "ap.api.fpjs.io"
    override_host = "ap.api.fpjs.io"
  }

  backend {
    address       = "fpcdn.io"
    name          = "fpcdn.io"
    override_host = "fpcdn.io"
  }

  force_destroy = true
  activate      = false

  lifecycle {
    ignore_changes = [
      package[0].source_code_hash
    ]
  }

  depends_on = [module.compute_asset]
}

resource "fastly_configstore" "integration_config_store" {
  name = "${var.config_store_prefix}${fastly_service_compute.fingerprint_integration.id}"
}

resource "fastly_configstore_entries" "integration_config_store_entries" {
  store_id = fastly_configstore.integration_config_store.id
  entries = {
    AGENT_SCRIPT_DOWNLOAD_PATH = var.agent_script_download_path
    GET_RESULT_PATH            = var.get_result_path
  }
}

resource "fastly_secretstore" "integration_secret_store" {
  name = "${var.secret_store_prefix}${fastly_service_compute.fingerprint_integration.id}"
}

resource "restapi_object" "add_proxy_secret" {
  data = jsonencode({ "name" = "PROXY_SECRET", "secret" = base64encode(var.proxy_secret) })
  path          = "/resources/stores/secret/${fastly_secretstore.integration_secret_store.id}/secrets"
  depends_on = [fastly_secretstore.integration_secret_store]
  object_id     = "PROXY_SECRET"
  update_method = "PUT"
  lifecycle {
    ignore_changes = all
  }
}

resource "restapi_object" "link_config_store" {
  data = jsonencode({
    "name"        = fastly_configstore.integration_config_store.name,
    "resource_id" = fastly_configstore.integration_config_store.id
  })
  path = "/service/${fastly_service_compute.fingerprint_integration.id}/version/${fastly_service_compute.fingerprint_integration.cloned_version}/resource"
  depends_on = [
    fastly_configstore.integration_config_store, fastly_configstore_entries.integration_config_store_entries
  ]
  id_attribute = "id"
  lifecycle {
    ignore_changes = all
  }
}

resource "restapi_object" "link_secret_store" {
  data = jsonencode({
    "name"        = fastly_secretstore.integration_secret_store.name,
    "resource_id" = fastly_secretstore.integration_secret_store.id
  })
  path = "/service/${fastly_service_compute.fingerprint_integration.id}/version/${fastly_service_compute.fingerprint_integration.cloned_version}/resource"
  depends_on = [
    restapi_object.add_proxy_secret, fastly_secretstore.integration_secret_store
  ]
  id_attribute = "id"
  lifecycle {
    prevent_destroy = true
    ignore_changes = all
  }
}

resource "restapi_object" "activate_service" {
  count = var.activate_service ? 1 : 0
  data           = ""
  path           = "/service/${fastly_service_compute.fingerprint_integration.id}/version/${fastly_service_compute.fingerprint_integration.cloned_version}/activate"
  create_method  = "PUT"
  id_attribute   = "service_id"
  destroy_method = "PUT"
  destroy_path   = "/service/${fastly_service_compute.fingerprint_integration.id}/version/${fastly_service_compute.fingerprint_integration.cloned_version}/deactivate"

  depends_on = [
    restapi_object.add_proxy_secret,
    restapi_object.link_config_store,
    restapi_object.link_secret_store,
  ]
}
