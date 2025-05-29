# Prerequisites

* Create a `terraform.tfvars` file, fill your `fastly_api_key`, `integration_domain`, `main_host`, `get_result_path`, `agent_script_download_path`, `proxy_secret`
* Create an empty Fastly Compute service and copy the id
* Paste the id in `terraform.tfvars` file like this:
```terraform
service_id = "<your_service_id>"
```
  
# Deploy

After filling `terraform.tfvars` file, run these in order:
```shell
terraform init
terraform apply -target=module.compute_asset
terraform import fastly_service_compute.fingerprint_integration "<your_service_id>"
terraform apply
```

# Custom Package

If you want to use your own asset instead of downloading latest follow these steps:

Place your custom asset in `<project_root>/assets/custom-asset.tar.gz` and then edit your `terraform.tfvars` file, and add these 2 variables:
```terraform
download_asset = false
compute_asset_name = "custom-asset.tar.gz"
```

Run these commands:
```shell
terraform init
terraform import fastly_service_compute.fingerprint_integration "<your_service_id>"
terraform apply
```

# Destroy

To destroy, run this:
```shell
terraform destroy
```

# Limitations & Known Issues

* In our implementation for Fastly Compute, we support multiple proxy integrations in one account, in order to do this, we bind store names with compute service id.
To apply this on terraform, we run in to cyclical dependency problem. In order to fix this, we rely on already created empty service and its ID.
* Fastly Terraform Provider officially doesn't support storing secret items via terraform.
So we are using MasterCard's RestApi provider to put our `PROXY_SECRET`.
* If you use your own custom asset, then you need to maintain your asset's version on your own!
* If you use plugin system for Fastly Compute Proxy Integration, this module doesn't support KV Store yet! It'll be implemented in the future
* This module doesn't create TLS certificate for your service yet! It'll be implemented in the future
