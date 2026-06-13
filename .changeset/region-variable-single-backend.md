---
"@fingerprint/terraform-fastly-compute-proxy": minor
---

Add `region` variable (`us`, `eu`, `ap`). When set, a single backend named `fingerprint` is created for the specified region and legacy regional backends are removed. When not set, legacy backends are kept for backward compatibility with a deprecation warning.
