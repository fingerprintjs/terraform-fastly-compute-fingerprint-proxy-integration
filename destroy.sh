#!/bin/bash
set -e

echo "Removing managed resources from state..."
terraform state rm restapi_object.link_config_store || true
terraform state rm restapi_object.link_secret_store || true

echo "Destroying config store..."
terraform destroy -auto-approve -target=fastly_configstore.integration_config_store

echo "Destroying secret store..."
terraform destroy -auto-approve -target=fastly_secretstore.integration_secret_store

echo "Running final destroy..."
terraform destroy -auto-approve
