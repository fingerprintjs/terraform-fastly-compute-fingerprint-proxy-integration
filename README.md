<p align="center">
<a href="https://fingerprint.com">
<picture>
<source media="(prefers-color-scheme: dark)" srcset="https://fingerprintjs.github.io/home/resources/logo_light.svg" />
<source media="(prefers-color-scheme: light)" srcset="https://fingerprintjs.github.io/home/resources/logo_dark.svg" />
<img src="https://fingerprintjs.github.io/home/resources/logo_dark.svg" alt="Fingerprint logo" width="312px" />
</picture>
</a>
</p>

# Fingerprint Pro Fastly Compute Integration (Terraform module)

[Fingerprint](https://fingerprint.com/) is a device intelligence platform offering industry-leading accuracy.

Fingerprint Pro Fastly Compute Integration is responsible for

- Proxying download requests of the latest Fingerprint Pro JS Agent between your site and Fingerprint CDN.
- Proxying identification requests and responses between your site and Fingerprint Pro's APIs.

This [improves](https://dev.fingerprint.com/docs/fastly-compute-proxy-integration#the-benefits-of-using-the-fastly-compute-proxy-integration) both accuracy and reliability of visitor identification and bot detection on your site.

You can install the Fastly Compute proxy integration [manually](https://dev.fingerprint.com/docs/deploy-fastly-compute-manually) or as [a Terraform module](https://registry.terraform.io/modules/fingerprintjs/fingerprint-fastly-proxy-integration/compute/latest) included in this repository. For more details, see the [full documentation](https://dev.fingerprint.com/docs/fastly-compute-proxy-integration).

## Requirements

- [Fastly](https://www.fastly.com/signup) Account
- [Terraform CLI](https://developer.hashicorp.com/terraform/install).
- An [empty Fastly Compute Service](https://manage.fastly.com/compute/new) ID
- [Fastly API Token](https://manage.fastly.com/account/tokens)

> [!IMPORTANT]  
> The Fastly Compute Proxy Integration is exclusively supported for customers on the Enterprise Plan. Other customers are encouraged to use [Custom subdomain setup](https://dev.fingerprint.com/docs/custom-subdomain-setup) or [Cloudflare Proxy Integration](https://dev.fingerprint.com/docs/cloudflare-integration).

> [!WARNING]  
> The underlying data contract in the identification logic can change to keep up with browser updates. Using the Fastly Compute Proxy Integration might require occasional manual updates on your side. Ignoring these updates will lead to lower accuracy or service disruption.

## Getting started

- Create your own terraform folder and create main.tf file
- Fill the file like this:

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

The properties you see here come from the Fingerprint module's variables, you can see the full list of properties below:

| Variable                       | Description                                             | Required | Example                                                 |
|--------------------------------|---------------------------------------------------------|----------|---------------------------------------------------------|
| `fastly_api_token`             | Your Fastly API token                                   | Required | `"ABC123...xyz"`                                        |
| `integration_domain`           | Domain used for your proxy integration                  | Required | `"metrics.yourdomain.com"`                              |
| `service_id`                   | ID of your empty Fastly Compute service                 | Required | `"SU1Z0isxPaozGVKXdv0eY"`                               |
| `agent_script_download_path`   | Path to serve agent script from your domain             | Required | `"4fs80xgx"`                                            |
| `get_result_path`              | Path to serve identification and browser cache requests | Required | `"vpyr9bev"`                                            |
| `integration_name`             | Name of Fastly service                                  | Optional | `"fingerprint-fastly-compute-proxy-integration"`        |
| `download_asset`               | Whether to auto-download latest release                 | Optional | `true`                                                  |
| `compute_asset_name`           | Custom filename if not downloading                      | Optional | `"fingerprint-fastly-compute-proxy-integration.tar.gz"` |
| `asset_version`                | GitHub release version of proxy integration             | Optional | `"latest"`                                              |
| `kv_store_enabled`             | Enable KV store integration                             | Optional | `false`                                                 |
| `kv_store_save_plugin_enabled` | Enables plugin to save to KV store                      | Optional | `"false"`                                               |
| `fpjs_backend_url`             | Domain for Ingress endpoint & browser cache endpoint    | Optional | `"api.fpjs.io"`                                         |
| `fpjs_cdn_url`                 | Domain for Agent Script                                 | Optional | `"fpcdn.io"`                                            |
  
## Deploy

Run these commands in order
```shell
terraform apply -target=module.fingerprint_fastly_compute_integration.module.compute_asset
terraform import module.fingerprint_fastly_compute_integration.fastly_service_compute.fingerprint_integration "<your empty fastly compute service id>"
terraform apply
```

## Custom package

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

## Destroy

To destroy, run this:
```shell
terraform destroy
```

## Limitations

* In our implementation for Fastly Compute, we support multiple proxy integrations in one account, in order to do this, we bind store names with compute service id.
To apply this on terraform, we run in to cyclical dependency problem. In order to fix this, we rely on already created empty service and its ID.
* If you use your own custom asset, then you need to maintain your asset's version on your own!
