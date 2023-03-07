resource "null_resource" "monitoring-init" {
  provisioner "local-exec" {
    command = "sh ./scripts/monitoring.sh ${var.container_cluster.name} ${var.ecm_compute_network.zones.zone_subnet_1} ${var.ecm_provider.project}"
  }

  depends_on = [
    google_container_cluster.ecm-cluster,
    google_container_node_pool.ecm-pool,
    google_project_service.service
  ]
}
