---
"@fingerprint/terraform-fastly-compute-proxy": minor
---

Remove plugin system and KV store support as the plugin system has been removed from fastly-compute-proxy v4. `kv_store_enabled` and `kv_store_prefix` are kept as no-op variables for backward compatibility and will be removed in a future major version.
