data "google_client_config" "default" {}

locals {
  mesh_key_ingress =  "${var.name}-ingress"

  cm_email = "${module.ingress-service-account.sa-account-id}@${data.google_client_config.default.project}.iam.gserviceaccount.com"
}

resource "google_compute_address" "ip_address" {
  name = "${var.name}-external-ip"
}

module "ingress-service-account" { # certs + dns
  source = "../mesh-service-account"

  role = "roles/editor"
  name = local.mesh_key_ingress
}

resource "helm_release" "cert-manager" {
  name = "cert-manager"
  namespace = var.namespace-cm
  repository = "https://charts.jetstack.io"
  chart = "cert-manager"

  set {
    name = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "ingress" {
  name = "ingress"
  namespace = var.namespace-lb

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"

  set {
    name = "controller.service.loadBalancerIP"
    value = google_compute_address.ip_address.address
  }
  set {
    name = "rbac.create"
    value = true
  }
}

module "google_dns_record_set" {
  source = "terraform-google-modules/cloud-dns/google"
  version = "3.0.0"

  project_id = data.google_client_config.default.project

  type = "public"

  name = "${local.mesh_key_ingress}-zone"
  domain = "${var.domain}."

  recordsets = [
    {
      name = "*"
      type = "A"
      ttl = 300
      records = [
        google_compute_address.ip_address.address
      ]
    },
  ]
}


resource "kubernetes_manifest" "cert-issuer-prod" {
  depends_on = [
    helm_release.cert-manager
  ]
  manifest = {
    kind = "ClusterIssuer"
    apiVersion = "cert-manager.io/v1"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email = "xx"
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
  }
}
