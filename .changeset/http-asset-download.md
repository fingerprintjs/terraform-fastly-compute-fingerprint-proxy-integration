---
"@fingerprint/terraform-fastly-compute-proxy": major
---

The module now picks the Compute package release at plan time and downloads it again when a new release is out, so `terraform apply` keeps the integration up to date. It only uses v0.4.x releases of the package, so a future v0.5 package with breaking changes is never applied by this major version. `asset_version` accepts `"latest"` or a v0.4.x tag. Replace `download_asset = false` with the new `custom_package` variable. The `terraform apply -target` step and the `integrations/github` provider are no longer needed.
