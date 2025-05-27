Create a "terraform.vars" file, use the "terraform.vars.example", fill it with correct info.

Run `terraform init`
Run `terraform plan`
Run `terraform apply`


To say, run these in order:
```shell
terraform state rm restapi_object.link_config_store \
terraform state rm restapi_object.link_secret_store \
terraform destroy -target=fastly_configstore.integration_config_store \
terraform destroy -target=fastly_secretstore.integration_secret_store \
terraform destroy
```

Or simply run:
```shell
./destroy.sh
```
