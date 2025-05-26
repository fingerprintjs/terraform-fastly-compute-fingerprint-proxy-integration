terraform {
  required_providers {
    fastly = {
      source  = "fastly/fastly"
      version = ">= 7.0.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.2.2"
    }
  }
}

provider "fastly" {
  api_key = var.fastly_api_key
}

resource "fastly_service_compute" "fingerprint_integration" {
  name = var.integration_name

  domain {
    name = var.integration_domain
  }

  domain {
    for_each = var.test_domain_name == "" ? [] : [0]
    name = "${var.test_domain_name}.edgecompute.app"
  }

  package {
    filename         = data.local_file.compute_asset.filename
    source_code_hash = filebase64sha512(local.compute_local_path)
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

resource "null_resource" "add_proxy_secret" {
  provisioner "local-exec" {
    command = <<EOT
      bash ${path.module}/scripts/add_secret_to_secret_store.sh \
        ${fastly_secretstore.integration_secret_store.id} \
        PROXY_SECRET \
        ${var.proxy_secret} \
        ${var.fastly_api_key}
    EOT
  }

  triggers = {
    service_version = fastly_service_compute.fingerprint_integration.cloned_version
  }

  depends_on = [fastly_secretstore.integration_secret_store]
}

resource "null_resource" "resource_link_config_store" {
  provisioner "local-exec" {
    command = <<EOT
      bash ${path.module}/scripts/create_resource_link.sh \
        ${fastly_service_compute.fingerprint_integration.id} \
        ${fastly_service_compute.fingerprint_integration.cloned_version} \
        ${fastly_configstore.integration_config_store.id} \
        ${fastly_configstore.integration_config_store.name} \
        ${var.fastly_api_key}
    EOT
  }

  triggers = {
    service_version = fastly_service_compute.fingerprint_integration.cloned_version
  }

  depends_on = [fastly_configstore.integration_config_store]
}

resource "null_resource" "resource_link_secret_store" {
  provisioner "local-exec" {
    command = <<EOT
      bash ${path.module}/scripts/create_resource_link.sh \
        ${fastly_service_compute.fingerprint_integration.id} \
        ${fastly_service_compute.fingerprint_integration.cloned_version} \
        ${fastly_secretstore.integration_secret_store.id} \
        ${fastly_secretstore.integration_secret_store.name} \
        ${var.fastly_api_key}
    EOT
  }

  triggers = {
    service_version = fastly_service_compute.fingerprint_integration.cloned_version
  }

  depends_on = [null_resource.add_proxy_secret, fastly_secretstore.integration_secret_store]
}

resource "null_resource" "activate_service" {
  provisioner "local-exec" {
    command = <<EOT
      bash ${path.module}/scripts/activate_fastly.sh \
        ${fastly_service_compute.fingerprint_integration.id} \
        ${fastly_service_compute.fingerprint_integration.cloned_version} \
        ${var.fastly_api_key}
    EOT
  }

  triggers = {
    service_version = fastly_service_compute.fingerprint_integration.cloned_version
  }

  depends_on = [
    null_resource.resource_link_secret_store,
    null_resource.resource_link_config_store
  ]
}
