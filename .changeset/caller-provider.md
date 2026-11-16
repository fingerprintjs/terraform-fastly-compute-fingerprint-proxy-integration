---
"@fingerprint/terraform-fastly-compute-proxy": major
---

The module no longer configures the `fastly` provider, so it can be used with `count`, `for_each` and `depends_on`. Configure `provider "fastly"` in your own configuration and remove `fastly_api_token` from the module block. Also remove the `kv_store_enabled` and `kv_store_prefix` variables, which had no effect since v1.1.0.
