terraform {
  required_version = ">= 0.14.0"
}

locals {
  mesh_key = "${var.name}${var.environment != "" ? "-${var.environment}" : ""}"
  mesh_key_network = "${local.mesh_key}-network"

  primary_range_pods = "${local.mesh_key_network}-range-pods"
  primary_range_nodes = "${local.mesh_key_network}-range-primary"
  primary_range_services = "${local.mesh_key_network}-range-services"
}

data "google_client_config" "default" {}

provider "google-beta" {
  zone = data.google_client_config.default.zone
  region = data.google_client_config.default.region
  project = data.google_client_config.default.project
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  experiments {
    manifest_resource = true
  }
}

provider "helm" {
  kubernetes {
    host = module.cluster-auth.host
    token = module.cluster-auth.token
    cluster_ca_certificate = base64decode(module.cluster.cluster-cert)
  }
}

module "cluster" {
  source = "./modules/mesh-cluster"

  depends_on = [
    module.cluster-network
  ]

  name = local.mesh_key
  network = {
    name = local.mesh_key_network
    ranges = {
      range_pods = local.primary_range_pods
      range_nodes = local.primary_range_nodes,
      range_services = local.primary_range_services
    }
    range = local.primary_range_nodes
  }
}

module "cluster-service" {
  source = "./modules/mesh-service"

  for_each = var.services

  name = each.key
  image = each.value.image

  port = lookup(each.value, "port", 80)
}
module "cluster-network" {
  source = "./modules/mesh-network"
  name = local.mesh_key_network

  subnets = [
    {
      range = var.default_primary_range_nodes
      region = data.google_client_config.default.region
      name = local.primary_range_nodes
      secondary = [
        {
          range = var.default_primary_range_pods
          name = local.primary_range_pods
        },
        {
          range = var.default_primary_range_services
          name = local.primary_range_services
        }]
    }
  ]
}

module "cluster-auth" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  location = module.cluster.cluster-location
  project_id = data.google_client_config.default.project
  cluster_name = local.mesh_key
}

resource "kubernetes_namespace" "cm" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_namespace" "lb" {
  metadata {
    name = "ingress"
  }
}

module "ingress" {
  source = "./modules/mesh-ingress"
  depends_on = [
    module.cluster-auth
  ]

  name = local.mesh_key

  namespace-lb = kubernetes_namespace.lb.metadata[0].name
  namespace-cm = kubernetes_namespace.cm.metadata[0].name

  domain = var.domain
}
