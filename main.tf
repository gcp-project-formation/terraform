resource "null_resource" "connect-to-gcloud" {
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = "gcloud auth login --cred-file=./key.json --quiet && gcloud config set project ${var.ecm_provider.project}"
  }
}

resource "google_compute_network" "vpc-ecm" {
  name                    = var.ecm_compute_network.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_firewall" "allow-ssh-http" {
  name          = "allow-ssh-http"
  network       = google_compute_network.vpc-ecm.name
  source_tags   = ["allow-ssh-http"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["80", "22", "6379"]
  }

  depends_on = [
    null_resource.connect-to-gcloud
  ]
}

resource "google_compute_router" "router" {
  name    = var.router_name
  region  = var.ecm_compute_network.regions.region_subnet_1
  network = google_compute_network.vpc-ecm.id

  depends_on = [
    google_compute_network.vpc-ecm
  ]
}

resource "google_compute_router_nat" "nat" {
  name                               = var.nat_name
  router                             = google_compute_router.router.name
  region                             = var.ecm_compute_network.regions.region_subnet_1
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_subnetwork" "subnet-ecm-1" {
  name          = var.ecm_compute_network.subnetwork.names.subnet_ecm_name_1
  ip_cidr_range = var.ecm_compute_network.subnetwork.ip_ranges.ip_range_subnet_1
  region        = var.ecm_compute_network.regions.region_subnet_1
  network       = google_compute_network.vpc-ecm.self_link

  secondary_ip_range {
    range_name    = "k8s-pod-range"
    ip_cidr_range = "10.48.0.0/14"
  }
  secondary_ip_range {
    range_name    = "k8s-service-range"
    ip_cidr_range = "10.52.0.0/20"
  }

  depends_on = [
    google_compute_network.vpc-ecm
  ]
}

resource "google_compute_subnetwork" "subnet-ecm-2" {
  name          = var.ecm_compute_network.subnetwork.names.subnet_ecm_name_2
  ip_cidr_range = var.ecm_compute_network.subnetwork.ip_ranges.ip_range_subnet_2
  region        = var.ecm_compute_network.regions.region_subnet_2
  network       = google_compute_network.vpc-ecm.self_link

  depends_on = [
    google_compute_network.vpc-ecm
  ]
}

resource "google_compute_network_endpoint_group" "neg-1" {
  name         = var.ecm_compute_network.endpoint_group.names.lb_neg_name_1
  network      = google_compute_network.vpc-ecm.id
  subnetwork   = google_compute_subnetwork.subnet-ecm-1.id
  default_port = var.ecm_compute_network.endpoint_group.port
  zone         = var.ecm_compute_network.zones.zone_subnet_1
}

resource "google_compute_network_endpoint_group" "neg-2" {
  name         = var.ecm_compute_network.endpoint_group.names.lb_neg_name_2
  network      = google_compute_network.vpc-ecm.id
  subnetwork   = google_compute_subnetwork.subnet-ecm-1.id
  default_port = var.ecm_compute_network.endpoint_group.port
  zone         = var.ecm_compute_network.zones.zone_subnet_2
}

resource "google_compute_network_endpoint_group" "neg-3" {
  name         = var.ecm_compute_network.endpoint_group.names.lb_neg_name_3
  network      = google_compute_network.vpc-ecm.id
  subnetwork   = google_compute_subnetwork.subnet-ecm-2.id
  default_port = var.ecm_compute_network.endpoint_group.port
  zone         = var.ecm_compute_network.zones.zone_subnet_3
}
