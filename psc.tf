# This file configures the Private Service Connect (PSC) resources.
# It creates a service attachment to expose the internal service
# and a forwarding rule to make it accessible from the external network.

resource "google_compute_service_attachment" "psc_attachment" {
  provider               = google.app
  name                   = "psc-attachment"
  enable_proxy_protocol  = true
  connection_preference  = "ACCEPT_AUTOMATIC"
  nat_subnets            = [google_compute_subnetwork.vpc_app_subnet.self_link]
  target_service         = google_compute_forwarding_rule.internal.self_link
}

resource "google_compute_forwarding_rule" "psc_endpoint" {
  provider    = google.external
  name        = "psc-endpoint"
  network     = google_compute_network.vpc_external.name
  target = google_compute_service_attachment.psc_attachment.self_link
}