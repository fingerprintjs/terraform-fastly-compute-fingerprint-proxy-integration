# Prerequisites

* Create a `terraform.tfvars` file, fill your `fastly_api_key`, `integration_domain`, `main_host`, `get_result_path`, `agent_script_download_path`
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

> After you deployed your service via terraform, you need to add Secret Store item with key PROXY_SECRET
> to Secret Store created via Terraform and fill your value. This approach is suggested by Fastly. For details please see [this link](https://registry.terraform.io/providers/fastly/fastly/latest/docs/resources/secretstore) and check Note section.

# Destroy

To destroy, run this:
```shell
terraform destroy
```

# Limitations & Known Issues

* In our implementation for Fastly Compute, we support multiple proxy integrations in one account, in order to do this, we bind store names with compute service id.
To apply this on terraform, we run in to cyclical dependency problem. In order to fix this, we rely on already created empty service and its ID.
* If you use your own custom asset, then you need to maintain your asset's version on your own!
