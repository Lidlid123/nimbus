# This file configures the Google Cloud provider for Terraform.
# It sets up the required provider version and defines a default provider
# as well as aliased providers for the external and application projects.

terraform {
  required_providers { google = { source = "hashicorp/google" } }
  required_version = ">= 1.3"
}

provider "google" {
  project = "project-1-467413"
  region  = "us-central1"
}

provider "google" {
  alias   = "external"
  project = "project-1-467413"
  region  = "us-central1"
}

provider "google" {
  alias   = "app"
  project = "project-2-467413"
  region  = "us-central1"
}
