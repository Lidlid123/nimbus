# This file configures the external-facing components of the load balancer.
# It creates a managed SSL certificate, a Cloud Armor security policy,
# and the necessary forwarding rules and proxies to expose the service to the internet.

# Managed SSL for example.com
resource "google_compute_managed_ssl_certificate" "cert" {
  provider = google.external
  name     = "external-lb-cert"
  managed { domains = [var.domain] }
}

# Cloud Armor WAF
resource "google_compute_security_policy" "armor" {
  provider = google.external
  name     = "external-armor"
  rule {
    priority = 1000
    action   = "allow"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}

# External Backend Service (PSC target will attach)
resource "google_compute_backend_service" "external_be" {
  provider       = google.external
  name           = "external-be"
  protocol       = "HTTPS"
  security_policy = google_compute_security_policy.armor.self_link
  backend {
    group = google_compute_region_network_endpoint_group.psc_neg.id
  }
}

resource "google_compute_region_network_endpoint_group" "psc_neg" {
  provider              = google.external
  name                  = "psc-neg"
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = google_compute_forwarding_rule.psc_endpoint.self_link
  network               = google_compute_network.vpc_external.self_link
  region                = "us-central1"
}

resource "google_compute_url_map" "external" {
  provider         = google.external
  name             = "external-url-map"
  default_service  = google_compute_backend_service.external_be.id
}

resource "google_compute_target_https_proxy" "external" {
  provider        = google.external
  name            = "external-proxy"
  ssl_certificates = [google_compute_managed_ssl_certificate.cert.id]
  url_map          = google_compute_url_map.external.id
}

resource "google_compute_global_forwarding_rule" "external" {
  provider            = google.external
  name                = "external-https"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range          = "443"
  target              = google_compute_target_https_proxy.external.id
}