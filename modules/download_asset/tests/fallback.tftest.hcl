# Offline tests for picking the Compute package release. Run with `terraform test` in modules/download_asset (Terraform >= 1.7).

mock_provider "http" {
  mock_data "http" {
    defaults = {
      status_code = 200
    }
  }
}

override_data {
  target = data.http.tags[0]
  values = {
    status_code   = 200
    response_body = "[{\"ref\":\"refs/tags/v0.4.0\"},{\"ref\":\"refs/tags/v0.4.0-rc.0\"},{\"ref\":\"refs/tags/v0.4.1\"},{\"ref\":\"refs/tags/v0.4.2\"},{\"ref\":\"refs/tags/v0.4.10\"},{\"ref\":\"refs/tags/v0.3.1\"}]"
  }
}

run "latest_picks_newest_by_semver" {
  command = plan
  assert {
    condition     = output.version == "v0.4.10"
    error_message = "got ${output.version}"
  }
  assert {
    condition     = jsonencode(local.candidate_tags) == jsonencode(["v0.4.10", "v0.4.2", "v0.4.1"])
    error_message = "got ${jsonencode(local.candidate_tags)}"
  }
  assert {
    condition     = endswith(local.filename, "/downloads/v0.4.10-fingerprint-fastly-compute-proxy-integration.tar.gz")
    error_message = "got ${local.filename}"
  }
}

run "falls_back_on_404" {
  command = plan
  override_data {
    target = data.http.asset_check[0]
    values = { status_code = 404 }
  }
  assert {
    condition     = output.version == "v0.4.2"
    error_message = "got ${output.version}"
  }
}

run "fails_on_503_instead_of_falling_back" {
  command = plan
  override_data {
    target = data.http.asset_check[0]
    values = { status_code = 503 }
  }
  expect_failures = [data.http.asset_check[0]]
}

run "fails_when_all_candidates_404" {
  command = plan
  override_data {
    target = data.http.asset_check[0]
    values = { status_code = 404 }
  }
  override_data {
    target = data.http.asset_check[1]
    values = { status_code = 404 }
  }
  override_data {
    target = data.http.asset_check[2]
    values = { status_code = 404 }
  }
  expect_failures = [terraform_data.download]
}

run "pinned_version_is_only_candidate" {
  command = plan
  variables {
    asset_version = "v0.4.1"
  }
  assert {
    condition     = output.version == "v0.4.1" && jsonencode(local.candidate_tags) == jsonencode(["v0.4.1"])
    error_message = "got ${output.version}"
  }
}

run "pinned_other_line_rejected" {
  command = plan
  variables {
    asset_version = "v0.3.1"
  }
  expect_failures = [data.http.asset_check[0]]
}

run "single_tag_fills_all_candidates" {
  command = plan
  override_data {
    target = data.http.tags[0]
    values = {
      status_code   = 200
      response_body = "[{\"ref\":\"refs/tags/v0.4.0\"},{\"ref\":\"refs/tags/v0.4.0-rc.0\"}]"
    }
  }
  assert {
    condition     = output.version == "v0.4.0" && jsonencode(local.candidate_tags) == jsonencode(["v0.4.0", "v0.4.0", "v0.4.0"])
    error_message = "got ${output.version} from ${jsonencode(local.candidate_tags)}"
  }
}

run "fails_without_stable_tags" {
  command = plan
  override_data {
    target = data.http.tags[0]
    values = {
      status_code   = 200
      response_body = "[{\"ref\":\"refs/tags/v0.4.0-rc.0\"}]"
    }
  }
  expect_failures = [terraform_data.download]
}
