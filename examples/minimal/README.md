## Minimal example for Fingerprint Fastly Compute Proxy Integration

This is an example Terraform using the [Fingerprint Fastly Compute proxy integration Terraform module](https://github.com/fingerprintjs/terraform-fastly-fingerprint-compute-proxy-integration).
Learn more in the [Fastly Compute Proxy Terraform installation guide](https://dev.fingerprint.com/docs/deploy-fastly-compute-using-terraform).

### Running the example

To quickly run the example for testing purposes, you can:

1. Create an empty Fastly Compute service in your Fastly account and note down its ID.
2. Copy the [terraform.tfvars.example](./terraform.tfvars.example) file into a new `terraform.tfvars` file and replace the values with your own.
    ```shell 
    cd examples/minimal && cp terraform.tfvars.example terraform.tfvars
    ```
    The variables are defined and described in the [variables.tf](./variables.tf) file.
3. Run `terraform init`
4. Run `terraform apply -target=module.fingerprint_fastly_compute_integration.module.compute_asset`. You can safely ignore warnings about resource targeting.
5. Run `terraform import module.fingerprint_fastly_compute_integration.fastly_service_compute.fingerprint_integration "EMPTY_FASTLY_COMPUTE_SERVICE_ID"`
6. Run `terraform apply`
7. Add a `PROXY_SECRET` item with your Fingerprint proxy secret to the Secret Store created for your service.

### Using in production

This is a simplified example. Use it as a reference but make sure to **adjust the code to your needs and security practices** before deploying it to production environments.

### Additional resources

- [Fingerprint Fastly Compute Proxy Integration documentation](https://dev.fingerprint.com/docs/fastly-compute-proxy-integration)
