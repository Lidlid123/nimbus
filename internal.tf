# This file configures the internal components of the load balancer.
# It sets up a private service connect (PSC) peering, a managed SSL certificate for internal traffic,
# a health check, a network endpoint group (NEG) for the GKE service,
# and the necessary backend services and forwarding rules.

# Reserve range for PSC peering
data "google_project" "self" { project_id = "project-2-467413" }

resource "google_compute_global_address" "psc_range" {
  provider      = google.app
  name          = "psc-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_app.name
}

resource "google_service_networking_connection" "psc" {
  provider                = google.app
  network                 = google_compute_network.vpc_app.name
  service                 = "services/compute.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psc_range.name]
}

# Internal cert + LB
resource "google_compute_managed_ssl_certificate" "int_cert" {
  provider = google.app
  name     = "internal-cert"
  managed { domains = ["internal.example.com"] }
}

resource "google_compute_health_check" "hc" {
  provider = google.app
  name     = "app-hc"
  https_health_check {
    port         = 9443
    request_path = "/"
  }
}

resource "google_compute_network_endpoint_group" "neg" {
  provider              = google.app
  name                  = "app-neg"
  network_endpoint_type = "GCE_VM_IP_PORT"
  network               = google_compute_network.vpc_app.name
  subnetwork            = google_compute_subnetwork.vpc_app_subnet.name
  zone                  = "us-central1-a"
}

resource "google_compute_backend_service" "int_be" {
  provider      = google.app
  name          = "internal-be"
  protocol      = "HTTPS"
  health_checks = [google_compute_health_check.hc.id]
  backend { group = google_compute_network_endpoint_group.neg.id }
}

resource "google_compute_url_map" "internal" {
  provider        = google.app
  name            = "internal-url-map"
  default_service = google_compute_backend_service.int_be.id
}

resource "google_compute_target_https_proxy" "internal" {
  provider        = google.app
  name            = "internal-proxy"
  url_map         = google_compute_url_map.internal.id
  ssl_certificates = [google_compute_managed_ssl_certificate.int_cert.id]
}

resource "google_compute_forwarding_rule" "internal" {
  provider               = google.app
  name                   = "internal-https"
  load_balancing_scheme  = "INTERNAL_MANAGED"
  network                = google_compute_network.vpc_app.name
  subnetwork             = google_compute_subnetwork.vpc_app_subnet.name
  ports                  = ["443"]
  target                 = google_compute_target_https_proxy.internal.id
}