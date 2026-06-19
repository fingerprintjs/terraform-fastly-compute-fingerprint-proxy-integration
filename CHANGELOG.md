## 1.1.0

### Minor Changes

- Make `agent_script_download_path` and `get_result_path` optional with null defaults. Config store and its entries are now conditionally created only when at least one entry has a non-default value. Remove `fpjs_cdn_url` variable and its associated backend. ([a754095](https://github.com/fingerprintjs/terraform-fastly-compute-fingerprint-proxy-integration/commit/a7540951f63cda9dbd3df9e68c8dedb552c5bb1f))
- Add `region` variable (`us`, `eu`, `ap`). When set, a single backend named `fingerprint` is created for the specified region and legacy regional backends are removed. When not set, legacy backends are kept for backward compatibility with a deprecation warning. ([9eab44b](https://github.com/fingerprintjs/terraform-fastly-compute-fingerprint-proxy-integration/commit/9eab44b7211a5017fd4b264d81d93e50f48be68a))
- Remove plugin system and KV store support as the plugin system has been removed from fastly-compute-proxy v4. `kv_store_enabled` and `kv_store_prefix` are kept as no-op variables for backward compatibility and will be removed in a future major version. ([9e89b9e](https://github.com/fingerprintjs/terraform-fastly-compute-fingerprint-proxy-integration/commit/9e89b9e2f142322d4dce80bdb1ad47a02d49ba4c))

## 1.0.0

### Minor Changes

- add example ([d55e148](https://github.com/fingerprintjs/terraform-fastly-compute-fingerprint-proxy-integration/commit/d55e148f531599d5b3a66f9e90ac8d584c62d2cd))
- add variable manage_fastly_config_store_entries ([760f4cd](https://github.com/fingerprintjs/terraform-fastly-compute-fingerprint-proxy-integration/commit/760f4cd2c3ea6f41eaceb934eface98ac0bbefb6))
- remove fastly secret store item ([d4a2283](https://github.com/fingerprintjs/terraform-fastly-compute-fingerprint-proxy-integration/commit/d4a228396503bc8f07c3e4aa3780de26baca9fd8))

### Patch Changes

- trigger initial release ([d7b97b2](https://github.com/fingerprintjs/terraform-fastly-compute-fingerprint-proxy-integration/commit/d7b97b2f5481cb221d5a2d47882861e648635a1f))
- update backends for compute compatability ([44b7966](https://github.com/fingerprintjs/terraform-fastly-compute-fingerprint-proxy-integration/commit/44b7966d42b6b5bb12d268f27181628b897f4622))
