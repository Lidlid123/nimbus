# This file configures the Virtual Private Cloud (VPC) networks.
# It creates two VPCs: one for the external-facing components and one for the application.

# External VPC
resource "google_compute_network" "vpc_external" {
  provider                = google.external
  name                    = "vpc-external"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_external_subnet" {
  provider      = google.external
  name          = "vpc-external-subnet"
  network       = google_compute_network.vpc_external.name
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
}

# App VPC
resource "google_compute_network" "vpc_app" {
  provider                = google.app
  name                    = "vpc-app"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_app_subnet" {
  provider      = google.app
  name          = "vpc-app-subnet"
  network       = google_compute_network.vpc_app.name
  ip_cidr_range = "10.0.2.0/24"
  region        = "us-central1"
}