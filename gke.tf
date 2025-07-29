# This file configures the Google Kubernetes Engine (GKE) cluster.
# It defines the cluster itself and a node pool for running the application.

resource "google_container_cluster" "gke" {
  provider                  = google.app
  name                      = "app-gke-cluster"
  location                  = "us-central1"
  network                   = google_compute_network.vpc_app.name
  subnetwork                = google_compute_subnetwork.vpc_app_subnet.name
  remove_default_node_pool  = true
  initial_node_count        = 1
}

resource "google_container_node_pool" "pool" {
  provider            = google.app
  name                = "primary-pool"
  cluster             = google_container_cluster.gke.name
  location            = google_container_cluster.gke.location
  initial_node_count  = 2
  node_config { machine_type = "e2-medium" }
}