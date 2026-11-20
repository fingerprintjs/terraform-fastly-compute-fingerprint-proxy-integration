## Example with several Fingerprint Fastly Compute Proxy Integrations

This example deploys one integration per entry in `integrations` with `for_each`, and prints the integration URLs and Secret Store names from the module outputs.
`count` and `depends_on` work on the module the same way.

Learn more in the [Fastly Compute Proxy Terraform installation guide](https://docs.fingerprint.com/docs/deploy-fastly-compute-using-terraform).

### Running the example

1. Create one empty Fastly Compute service per integration in your Fastly account and note down their IDs.
2. Copy [terraform.tfvars.example](./terraform.tfvars.example) into a new `terraform.tfvars` file and replace the values with your own.
    ```shell
    cd examples/multiple && cp terraform.tfvars.example terraform.tfvars
    ```
3. Set the `FASTLY_API_KEY` environment variable to your Fastly API token.
4. Run `terraform init`
5. Run `terraform apply`. The `import` blocks in [fingerprint.tf](./fingerprint.tf) import the empty services.
6. Add a `PROXY_SECRET` item with your Fingerprint proxy secret to each Secret Store in the `secret_store_names` output.

To remove the integrations, run `terraform destroy`.

### Using in production

This is a simplified example. Use it as a reference but make sure to **adjust the code to your needs and security practices** before deploying it to production environments.
