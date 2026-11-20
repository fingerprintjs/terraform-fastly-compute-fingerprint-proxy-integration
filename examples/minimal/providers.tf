terraform {
  required_version = ">= 1.5"
  required_providers {
    fastly = {
      source  = "fastly/fastly"
      version = ">= 7.1.0"
    }
  }
}

provider "fastly" {
  api_key = var.fastly_api_token
}
