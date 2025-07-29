# This file defines the outputs of the Terraform module.
# It outputs the IP addresses of the external and internal load balancers.

output "external_lb_ip" {
  value = google_compute_global_forwarding_rule.external.ip_address
}

output "internal_lb_ip" {
  value = google_compute_forwarding_rule.internal.ip_address
}