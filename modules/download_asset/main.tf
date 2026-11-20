# Downloads the Fingerprint Compute package from the GitHub releases of fastly-compute-proxy.
# - asset_version = "latest" picks the newest stable tag of the supported release line, for example v0.4.2
# - The integration is still on 0.x, where a minor release can break (0.4.0 removed the KV store plugins).
#   So the supported line is a minor version. A new line needs a new major version of this module
# - Tags come from the git matching-refs API, which returns all tags with the prefix in one response (no pagination)
# - A tag can exist before its asset is uploaded. HEAD requests check the 3 newest tags, and "latest" falls back
#   to the next one on HTTP 404 only, so a GitHub outage fails the plan instead of moving to an older package
# - The package is ~4 MB, so it is downloaded to a file instead of kept in Terraform state.
#   The file name has the tag, so a new release changes it and the service gets the new package
terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.0"
    }
  }
}

locals {
  supported_release_line = "0.4"
  repository             = "${var.repository_organization_name}/${var.repository_name}"
  tag_prefix             = "v${local.supported_release_line}."
  # Matches stable tags of the supported line only, for example v0.4.2. Captures the rest of the version after the prefix.
  tag_pattern = "^${replace(local.tag_prefix, ".", "\\.")}(\\d+(?:\\.\\d+)?)$"

  # Pre-release tags like v0.4.0-rc.0 also have the prefix, the pattern skips them
  stable_tags = var.asset_version == "latest" ? [
    for ref in jsondecode(data.http.tags[0].response_body) : trimprefix(ref.ref, "refs/tags/")
    if can(regex(local.tag_pattern, trimprefix(ref.ref, "refs/tags/")))
  ] : []
  # Zero-padded version parts, so sorting the keys as strings sorts the tags by version
  tags_by_sort_key = {
    for tag in local.stable_tags :
    join(".", [for part in split(".", regex(local.tag_pattern, tag)[0]) : format("%06d", tonumber(part))]) => tag
  }
  sorted_tags = [for key in reverse(sort(keys(local.tags_by_sort_key))) : local.tags_by_sort_key[key]]

  # Newest tags to try, in order. A pinned asset_version is the only candidate.
  # - The number of candidates only depends on asset_version, so it is known at plan time even when the
  #   tag lookup is deferred to apply, for example by depends_on on the module
  # - With fewer tags than candidates, the last candidates repeat the oldest tag. "none" means there is no tag
  candidate_count = var.asset_version == "latest" ? 3 : 1
  candidate_tags = var.asset_version == "latest" ? [
    for i in range(local.candidate_count) : try(local.sorted_tags[min(i, length(local.sorted_tags) - 1)], "none")
  ] : [var.asset_version]
  candidate_urls = [for tag in local.candidate_tags : "https://github.com/${local.repository}/releases/download/${tag}/${var.compute_asset_name}"]
  selected_index = try([for i, tag in local.candidate_tags : i if data.http.asset_check[i].status_code == 200][0], null)
  selected_tag   = local.selected_index == null ? null : local.candidate_tags[local.selected_index]

  # Relative to the root module, so the path in state is the same on every machine
  filename = "${path.module}/downloads/${coalesce(local.selected_tag, "none")}-${var.compute_asset_name}"
}

data "http" "tags" {
  count = var.asset_version == "latest" ? 1 : 0
  url   = "https://api.github.com/repos/${local.repository}/git/matching-refs/tags/${local.tag_prefix}"
  request_headers = {
    Accept = "application/vnd.github+json"
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Could not list the ${local.tag_prefix}x tags of ${local.repository}. GitHub returned HTTP ${self.status_code}."
    }
  }
}

# HEAD only, so the package doesn't end up in Terraform state
data "http" "asset_check" {
  count  = local.candidate_count
  url    = local.candidate_urls[count.index]
  method = "HEAD"

  lifecycle {
    precondition {
      condition     = var.asset_version == "latest" || can(regex(local.tag_pattern, var.asset_version))
      error_message = "asset_version must be \"latest\" or a ${local.tag_prefix}x release tag, got \"${var.asset_version}\"."
    }
    # 404 means the asset isn't uploaded (yet), anything else is an error
    postcondition {
      condition     = contains([200, 404], self.status_code)
      error_message = "Could not check ${var.compute_asset_name} in release ${local.candidate_tags[count.index]} of ${local.repository}. GitHub returned HTTP ${self.status_code}."
    }
  }
}

# Downloads the package when the selected release changes.
# Instances of the module (count, for_each) share the downloads folder and can download the same file at once,
# so each download goes to its own temp file and is renamed into place.
resource "terraform_data" "download" {
  input            = local.filename
  triggers_replace = [local.filename]

  provisioner "local-exec" {
    command = <<EOT
      set -e
      dir="$(dirname "${local.filename}")"
      mkdir -p "$dir"
      tmp="$(mktemp "$dir/.download.XXXXXX")"
      trap 'rm -f "$tmp"' EXIT
      curl -fsSL --retry 3 -o "$tmp" "${local.candidate_urls[local.selected_index]}"
      mv -f "$tmp" "${local.filename}"
    EOT
  }

  lifecycle {
    precondition {
      condition     = var.asset_version != "latest" || length(local.sorted_tags) > 0
      error_message = "${local.repository} has no stable ${local.tag_prefix}x release."
    }
    precondition {
      condition     = local.selected_tag != null
      error_message = "${var.compute_asset_name} is missing from release ${join(", ", distinct(local.candidate_tags))} of ${local.repository}."
    }
  }
}
