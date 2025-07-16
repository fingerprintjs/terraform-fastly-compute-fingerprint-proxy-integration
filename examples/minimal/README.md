## Minimal example for Fingerprint Fastly Compute Proxy Integration

This project is an example of how to create a Fastly Compute service for the [Fingerprint Fastly Compute proxy integration Terraform module](https://github.com/fingerprintjs/terraform-fastly-fingerprint-compute-proxy-integration).
Learn more in the [Fastly Compute Proxy Terraform installation guide](https://dev.fingerprint.com/docs/deploy-fastly-compute-using-terraform).

### Running the example

To quickly run the example for testing purposes, you can:

1. Copy the [terraform.tfvars.example](./terraform.tfvars.example) file into a new `terraform.tfvars` file and replace the values with your own. The variables are defined and described in the [variables.tf](./variables.tf) file
    ```shell 
    cd examples/minimal && cp terraform.tfvars.example terraform.tfvars
    ```
2. Copy your Fastly API token
3. Create an empty compute service on Fastly and copy its ID
4. Run `terraform init`
5. Run `terraform apply -target=module.fingerprint_fastly_compute_integration.module.compute_asset`
6. Run `terraform import module.fingerprint_fastly_compute_integration.fastly_service_compute.fingerprint_integration "<your empty fastly compute service id>"`
7. Run `terraform plan`
8. Run `terraform apply`

### Using in production

This is a simplified example. Use it as a reference but make sure to **adjust the code to your needs and security practices** before deploying it to production environments.

### Additional resources

- [Fingerprint Fastly Compute Proxy Integration documentation](https://dev.fingerprint.com/docs/fastly-compute-proxy-integration)
