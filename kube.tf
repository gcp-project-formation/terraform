# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster
resource "google_container_cluster" "ecm-cluster" {
  name                     = var.container_cluster.name
  location                 = var.ecm_compute_network.zones.zone_subnet_1
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.vpc-ecm.self_link
  subnetwork               = google_compute_subnetwork.subnet-ecm-1.self_link
  logging_service          = var.container_cluster.logging_service
  monitoring_service       = var.container_cluster.monitoring_service
  # networking_mode          = var.container_cluster.networking_mode

  # Optional, if you want multi-zonal cluster
  node_locations = [
    var.ecm_compute_network.zones.zone_subnet_2
  ]

  addons_config {
    http_load_balancing {
      disabled = true
    }
    horizontal_pod_autoscaling {
      disabled = true
    }
  }

  release_channel {
    channel = var.container_cluster.channel
  }

  workload_identity_config {
    workload_pool = var.container_cluster.workload_pool
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.container_cluster.cluster_secondary_range_name
    services_secondary_range_name = var.container_cluster.services_secondary_range_name
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.container_cluster.master_ipv4_cidr_block
  }

  depends_on = [
    google_compute_network.vpc-ecm
  ]
}

resource "google_container_node_pool" "ecm-pool" {
  name              = "ecm-pool"
  cluster           = google_container_cluster.ecm-cluster.id
  node_count        = 2
  max_pods_per_node = 30

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    disk_size_gb = "100"
    preemptible  = false
    machine_type = "e2-small"

    labels = {
      role = "ecm-pool"
    }

    # taint {
    #   key    = "instance_type"
    #   value  = "spot"
    #   effect = "NO_SCHEDULE"
    # }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
