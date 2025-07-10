# Prerequisites
* Create an empty compute service on Fastly and copy its ID.
* Copy your Fastly API token
* Create your own terraform folder and create main.tf file
* Fill the file like this:
```terraform
terraform {
  required_version = ">=1.5"
}

module "fingerprint_fastly_compute_integration" {
  source                     = "github.com/fingerprintjs/temp-fastly-compute-terraform"
  fastly_api_token             = "<your fastly api token>"
  integration_domain         = "<your domain to serve fingerprint integration>"
  service_id                 = "<your empty fastly compute service id>"
  agent_script_download_path = "<random path like this: qwe123>"
  get_result_path            = "<random path like this: asd987>"
}
```
* Run `terraform init`
  
# Deploy

Run these commands in order
```shell
terraform apply -target=module.fingerprint_fastly_compute_integration.module.compute_asset
terraform import module.fingerprint_fastly_compute_integration.fastly_service_compute.fingerprint_integration "<your empty fastly compute service id>"
terraform apply
```

# Custom Package

If you want to use your own asset instead of downloading latest follow these steps:

Place your custom asset in `<your_module_root>/assets/custom-asset.tar.gz` and then edit your `main.tf` file, and add these 2 variables inside "compute" module block:
```terraform
download_asset = false
compute_asset_name = "custom-asset.tar.gz"
```

Run these commands:
```shell
terraform init
terraform import module.fingerprint_fastly_compute_integration.fastly_service_compute.fingerprint_integration "<your empty fastly compute service id>"
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
