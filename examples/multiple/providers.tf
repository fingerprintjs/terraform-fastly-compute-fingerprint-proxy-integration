terraform {
  # import blocks with for_each need Terraform 1.7
  required_version = ">= 1.7"
  required_providers {
    fastly = {
      source  = "fastly/fastly"
      version = ">= 7.1.0"
    }
  }
}

# Reads the API token from the FASTLY_API_KEY environment variable
provider "fastly" {}
