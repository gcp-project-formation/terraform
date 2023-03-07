resource "random_uuid" "random_uid" {
}

resource "google_compute_firewall" "redis" {
  name          = "allow-redis"
  network       = "default"
  target_tags   = ["allow-redis"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22", "6379"]
  }
}

# RSA key of size 4096 bits
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.rsa_4096.private_key_pem
  filename        = ".ssh/redis_ssh"
  file_permission = "0600"
}

resource "google_compute_address" "static_ip" {
  name   = "redis-static-ip"
  region = var.redis_instance_value.region
}

resource "google_compute_instance" "redis-instance" {
  name         = var.redis_instance_value.name
  machine_type = var.redis_instance_value.machine_type
  zone         = var.redis_instance_value.zone
  tags         = var.redis_instance_value.tags

  boot_disk {
    initialize_params {
      image = var.redis_instance_value.image
    }
  }

  metadata = {
    ssh-keys = "${var.redis_instance_value.name}:${tls_private_key.rsa_4096.public_key_openssh}"
  }

  network_interface {
    network    = google_compute_network.vpc-ecm.name
    subnetwork = google_compute_subnetwork.subnet-ecm-2.name
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  provisioner "remote-exec" {
    inline = var.redis_instance_value.remote_exec.inline

    connection {
      host        = google_compute_address.static_ip.address
      type        = var.redis_instance_value.remote_exec.ssh_name
      user        = var.redis_instance_value.name
      private_key = tls_private_key.rsa_4096.private_key_pem
    }
  }

  provisioner "local-exec" {
    command = "cd ansible_redis && sh run_redis.sh ${google_compute_address.static_ip.address} ${var.redis_instance_value.name}"
  }

  depends_on = [
    tls_private_key.rsa_4096,
    google_compute_network.vpc-ecm
  ]
}

output "ssh_connect" {
  value = "ssh -i .ssh/redis_ssh ${var.redis_instance_value.name}@${google_compute_address.static_ip.address}"
}

output "ssh_connect_1" {
  sensitive = true
  value     = google_compute_instance.redis-instance
}

output "ssh_connect_2" {
  sensitive = true
  value     = google_compute_instance.redis-instance.network_interface.0.network_ip
}


# resource "google_compute_disk" "redis-disk" {
#   name  = "redis-disk"
#   type  = "pd-ssd"
#   zone  = "europe-west2-a"
#   image = "debian-11-bullseye-v20220719"
#   size  = 30
# }

# resource "google_compute_attached_disk" "redis-attach" {
#   disk     = google_compute_disk.redis-disk.id
#   instance = google_compute_instance.redis-instance.id
# }
