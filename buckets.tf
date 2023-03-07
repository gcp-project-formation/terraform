resource "google_storage_bucket" "static-site" {
  name          = "${var.bucket_name}${random_uuid.random_uid.result}"
  location      = "EU"
  force_destroy = true

  uniform_bucket_level_access = true


  provisioner "local-exec" {
    command = "cd ./manifests/prod/configMap/ && python3 updateConfigMap.py ${google_compute_instance.redis-instance.network_interface.0.network_ip} && cd - && gcloud storage cp -r ./manifests gs://${var.bucket_name}${random_uuid.random_uid.result}/"
  }

  depends_on = [
    google_compute_network.vpc-ecm
  ]
}
