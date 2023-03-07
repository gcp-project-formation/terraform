resource "null_resource" "kube-init" {
  provisioner "local-exec" {
    command = "cd ./manifests/scripts/ && sh kube_init.sh ${var.container_cluster.name} ${var.ecm_compute_network.zones.zone_subnet_1} ${var.ecm_provider.project} && gcloud config set project ${var.ecm_provider.project}"
  }

  depends_on = [
    google_container_cluster.ecm-cluster,
    google_container_node_pool.ecm-pool,
    google_storage_bucket.static-site
  ]
}

resource "google_cloudbuild_trigger" "filename-trigger" {
  for_each = var.bucket_repo_names
  location = each.value.location
  name     = "${each.value.deploy_type}-${each.value.name}"

  trigger_template {
    branch_name = each.value.branch_name
    repo_name   = "github_fil-rouge-ecm_${each.value.name}"
  }

  substitutions = {
    _BRANCH_NAME  = each.value.name
    _DEPLOY_VALUE = each.value.deploy_type
    _BUCKET_NAME  = "${var.bucket_name}${random_uuid.random_uid.result}"
    _LOCATION     = "${var.ecm_compute_network.zones.zone_subnet_1}"
    _CLUSTER      = "${var.container_cluster.name}"
  }

  filename = each.value.name == var.cart_service_name ? "src/cloudbuild.yaml" : "cloudbuild.yaml"

  depends_on = [
    null_resource.kube-init
  ]
}

resource "google_project_service" "service" {
  for_each                   = var.bucket_repo_names
  service                    = "cloudbuild.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false

  provisioner "local-exec" {
    command = "gcloud alpha builds triggers run ${each.value.deploy_type}-${each.value.name} --region=${each.value.location} --branch=${each.value.branch_name}"
  }

  depends_on = [
    google_cloudbuild_trigger.filename-trigger
  ]
}
