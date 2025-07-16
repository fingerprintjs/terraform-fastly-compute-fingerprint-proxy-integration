# Contributing to Fingerprint Pro Fastly Compute Integration Terraform Module

## Working with code


For proposing changes, use the standard [pull request approach](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request). It's recommended to discuss fixes or new functionality in the Issues, first.

* The `main` and `rc` branches are locked for the push action.
* Releases are created from the `main` branch. If you have Fastly Compute Integration set up, it is running code from the `main` branch. Pull requests into the `main` branch are not accepted.
* The `rc` branch functions as a candidate for the next release. Create your pull requests into this branch. The code in `rc` must always pass the tests.

### Code style

Consistent code formatting is enforced by [TFLint](https://github.com/terraform-linters/tflint) and [Prettier](https://prettier.io/).

### Security scans

We are using [Trivy](https://aquasecurity.github.io/trivy/v0.47/tutorials/misconfiguration/terraform/) to do security scans for us.

### Commit style

You are required to follow [conventional commits](https://www.conventionalcommits.org) rules.

### How to test

We manually test the implementation.

### How to release a new version

Every PR should target `rc` branch first. Upon merge, if there are relevant changes a new release candidate is created.
When that happens, an automated PR is created to `main` branch, and E2E tests run against it. If the tests pass, the PR can be merged and the release is created.

The integration is automatically released on every push to the main branch if there are relevant changes. The workflow must be approved by one of the maintainers, first.

## How to test without DNS and TLS Setup

To test terraform module on your Fastly Compute service, you can use Fastly subdomain `.edgecompute.app`. See example below:

```terraform
module "fingerprint_fastly_compute_integration" {
  # ...
  integration_domain = "my-test-subdomain.edgecompute.app" # <- Use subdomain here
}
```

## How test using Fingerprint Staging Environment

To test terraform module using Fingerprint's staging environment, you can alter origins like this:

```terraform
module "fingerprint_fastly_compute_integration" {
  # ...
  fpjs_backend_url = "api.stage.fpjs.sh" # <- Update Ingress origin here
  fpjs_cdn_url = "procdn.fpjs.sh" # <- Update CDN origin here
}
```
