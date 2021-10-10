locals {
  // Provided environment will in mesh resource names
  mesh_network_name = lookup(var.network.ranges, "range_nodes", var.network.range)
  mesh_network_range_pod = lookup(var.network.ranges, "range_pods", local.mesh_network_name)
  mesh_network_range_service = lookup(var.network.ranges, "range_services", local.mesh_network_name)

  mesh_key_cluster =  "${var.name}-cluster"
}

data "google_client_config" "default" {}

module "cluster-service-account" {
  source = "../mesh-service-account"

  role = "roles/editor"
  name = local.mesh_key_cluster
}

module "cluster" {
  source = "terraform-google-modules/kubernetes-engine/google"

  region = data.google_client_config.default.region
  project_id = data.google_client_config.default.project

  name = var.name
  network = var.network.name
  regional = true

  subnetwork = local.mesh_network_name
  ip_range_pods = local.mesh_network_range_pod
  ip_range_services = local.mesh_network_range_service

  network_policy = false
  horizontal_pod_autoscaling = true
  remove_default_node_pool = true
}
