locals {
  service_health = var.health-route

  service_port = var.port
  service_name = var.name
  service_image = var.image
}

resource "kubernetes_service" "service" {
  metadata {
    name = local.service_name
  }

  spec {
    selector = {
      app = local.service_name
    }
    session_affinity = "ClientIP"

    port {
      port        = 80
      target_port = local.service_port
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "service" {
  depends_on = [
  ]

  metadata {
    name = local.service_name
    labels = {
      app = local.service_name
    }
  }
  spec {
    replicas = 3

    selector {
      match_labels = {
        app = local.service_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.service_name
        }
      }

      spec {

        container {
          image = local.service_image
          name = local.service_name
          env_from {
            secret_ref {
              name = "${local.service_name}-config"
            }
          }

          liveness_probe {
            http_get {
              path = local.service_health
              port = local.service_port

              http_header {
                name = "X-Source"
                value = "health_check"
              }
            }

            initial_delay_seconds = lookup(each.value, "initial_delay", 3)
            period_seconds = lookup(each.value, "period", 3)
          }
        }
      }
    }
  }
}
