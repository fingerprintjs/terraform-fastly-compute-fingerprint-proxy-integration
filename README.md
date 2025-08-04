<p align="center">
<a href="https://fingerprint.com">
<picture>
<source media="(prefers-color-scheme: dark)" srcset="https://fingerprintjs.github.io/home/resources/logo_light.svg" />
<source media="(prefers-color-scheme: light)" srcset="https://fingerprintjs.github.io/home/resources/logo_dark.svg" />
<img src="https://fingerprintjs.github.io/home/resources/logo_dark.svg" alt="Fingerprint logo" width="312px" />
</picture>
</a>
</p>

<p align="center">
<a href="https://registry.terraform.io/modules/fingerprintjs/compute-fingerprint-proxy-integration/fastly/latest"><img src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fregistry.terraform.io%2Fv2%2Fmodules%2Ffingerprintjs%2Fcompute-fingerprint-proxy-integration%2Ffastly%3Finclude%3Dlatest-version&query=%24.included%5B0%5D.attributes.version&prefix=v&label=Terraform" alt="Current version"></a>
<a href="https://github.com/fingerprintjs/terraform-fastly-compute-fingerprint-proxy-integration"><img src="https://img.shields.io/github/v/release/fingerprintjs/terraform-fastly-compute-fingerprint-proxy-integration" alt="Current version"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/:license-mit-blue.svg" alt="MIT license"></a>
<a href="https://discord.gg/39EpE2neBg"><img src="https://img.shields.io/discord/852099967190433792?style=logo&label=Discord&logo=Discord&logoColor=white" alt="Discord server"></a>
</p>

# Fingerprint Fastly Compute Integration (Terraform module)

[Fingerprint](https://fingerprint.com/) is a device intelligence platform offering industry-leading accuracy.

Fingerprint Fastly Compute Integration is responsible for

- Proxying download requests of the latest Fingerprint JS Agent between your site and Fingerprint CDN.
- Proxying identification requests and responses between your site and Fingerprint's APIs.

This [improves](https://dev.fingerprint.com/docs/fastly-compute-proxy-integration#the-benefits-of-using-the-fastly-compute-proxy-integration) both accuracy and reliability of visitor identification and bot detection on your site.

You can install the Fastly Compute proxy integration [manually](https://dev.fingerprint.com/docs/deploy-fastly-compute-manually) or as [a Terraform module](https://registry.terraform.io/modules/fingerprintjs/compute-fingerprint-proxy-integration/fastly/latest) included in this repository. For more details, see the [full documentation](https://dev.fingerprint.com/docs/fastly-compute-proxy-integration).

## Requirements

- [Fastly](https://www.fastly.com/signup) Account
- [Terraform CLI](https://developer.hashicorp.com/terraform/install).
- [Fastly API Token](https://manage.fastly.com/account/tokens)

> [!IMPORTANT]  
> The Fastly Compute Proxy Integration is exclusively supported for customers on the Enterprise Plan. Other customers are encouraged to use [Custom subdomain setup](https://dev.fingerprint.com/docs/custom-subdomain-setup) or [Cloudflare Proxy Integration](https://dev.fingerprint.com/docs/cloudflare-integration).

> [!WARNING]  
> The underlying data contract in the identification logic can change to keep up with browser updates. Using the Fastly Compute Proxy Integration might require occasional manual updates on your side. Ignoring these updates will lead to lower accuracy or service disruption.

## How to install

### 1. Create an empty Fastly Compute Service

Create and empty Fastly Compute service, for example, using the [Fastly web interface](https://manage.fastly.com/compute/new). Note down the service ID.

### 2. Install the Terraform module

Add the module to your Terraform file (for example, `main.tf`) and configure it with your Fastly API token, [Fingerprint proxy secret](https://dev.fingerprint.com/docs/fastly-compute-proxy-integration#step-1-create-a-fingerprint-proxy-secret), integration domain, and other required values: 

```terraform
terraform {
  required_version = ">=1.5"
}

module "fingerprint_fastly_compute_integration" {
  source                     = "github.com/fingerprintjs/temp-fastly-compute-terraform"
  fastly_api_token           = "FASTLY_API_TOKEN"
  service_id                 = "EMPTY_FASTLY_COMPUTE_SERVICE_ID"
  agent_script_download_path = "AGENT_SCRIPT_DOWNLOAD_PATH"
  get_result_path            = "GET_RESULT_PATH"
  integration_domain         = "metrics.yourwebsite.com"
}
```

You can see the full list of the Terraform module's variables below:

| Variable                             | Description                                                                                                                                                                                    | Required | Example                                                 |
|--------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|---------------------------------------------------------|
| `fastly_api_token`                   | Your Fastly API token                                                                                                                                                                          | Required | `"ABC123...xyz"`                                        |
| `service_id`                         | ID of your empty Fastly Compute service                                                                                                                                                        | Required | `"SU1Z0isxPaozGVKXdv0eY"`                               |
| `agent_script_download_path`         | Path to serve agent script from your domain                                                                                                                                                    | Required | `"4fs80xgx"`                                            |
| `get_result_path`                    | Path to serve identification and browser cache requests                                                                                                                                        | Required | `"vpyr9bev"`                                            |
| `integration_domain`                 | Domain used for your proxy integration                                                                                                                                                         | Required | `"metrics.yourdomain.com"`                              |
| `integration_name`                   | Name of Fastly service                                                                                                                                                                         | Optional | `"fingerprint-fastly-compute-proxy-integration"`        |
| `download_asset`                     | Whether to auto-download latest release                                                                                                                                                        | Optional | `true`                                                  |
| `compute_asset_name`                 | Custom filename if not downloading                                                                                                                                                             | Optional | `"fingerprint-fastly-compute-proxy-integration.tar.gz"` |
| `asset_version`                      | GitHub release version of proxy integration                                                                                                                                                    | Optional | `"latest"`                                              |
| `kv_store_enabled`                   | Enable KV store integration                                                                                                                                                                    | Optional | `false`                                                 |
| `kv_store_save_plugin_enabled`       | Enables plugin to save to KV store                                                                                                                                                             | Optional | `"false"`                                               |
| `fpjs_backend_url`                   | Domain for Ingress endpoint & browser cache endpoint                                                                                                                                           | Optional | `"api.fpjs.io"`                                         |
| `fpjs_cdn_url`                       | Domain for Agent Script                                                                                                                                                                        | Optional | `"fpcdn.io"`                                            |
| `manage_fastly_config_store_entries` | Manage Fastly Config Store entries via terraform, see [Fastly documentation](https://registry.terraform.io/providers/fastly/fastly/latest/docs/resources/configstore_entries#manage_entries-1) | Optional | `false`                                                 |

### 3. Deploy your Terraform changes

1. Initialize the Terraform module

    ```shell
    terraform init
    ```

2. Apply the Compute Asset

    ```shell
    terraform apply -target=module.fingerprint_fastly_compute_integration.module.compute_asset
    ```

3. Import the Fastly service

    ```shell
    terraform import \
      module.fingerprint_fastly_compute_integration.fastly_service_compute.fingerprint_integration \
      "<your empty fastly compute service id>"
    ```

4. Apply the changes

    ```shell
    terraform apply
    ```
### 4. Add the proxy secret to your Fastly Secret Store

1. Using the [Fastly web interface](https://manage.fastly.com/compute), open the Secret Store created for your service by Terraform. It will be named `Fingerprint_Compute_Secret_Store_<SERVICE_ID>`.
2. Add a `PROXY_SECRET` item with your Fingerprint proxy secret as the value.

## Using a Custom package
 
To use your own  `.tar.gz` package instead of downloading the official release, please see [Using a custom build](https://dev.fingerprint.com/docs/deploy-fastly-compute-using-terraform#using-a-custom-build-optional) in the full integration guide.

This is only necessary if you're using [Open Client Response](https://dev.fingerprint.com/docs/open-client-response).

## Examples

This repository also includes an example Terraform project. Use this example only as a reference, and make sure to follow best practices when provisioning Fastly services:

- [Minimal example](./examples/minimal/)

## How to update

The Terraform module does include any mechanism for automatic updates. To keep your integration up to date, please run `terraform apply` regularly.

## More resources

- [Documentation](https://dev.fingerprint.com/docs/fastly-compute-proxy-integration)

## License

This project is licensed under the MIT license. See the [LICENSE](/LICENSE) file for more info.

