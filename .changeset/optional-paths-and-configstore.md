---
"@fingerprint/terraform-fastly-compute-proxy": minor
---

Make `agent_script_download_path` and `get_result_path` optional with null defaults. Config store and its entries are now conditionally created only when at least one entry has a non-default value. Remove `fpjs_cdn_url` variable and its associated backend.
