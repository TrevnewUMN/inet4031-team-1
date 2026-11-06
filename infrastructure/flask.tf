resource "kubernetes_deployment" "flask" {
  metadata {
    name      = "flask"
    namespace = "default"
    labels = {
      app = "flask"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "flask"
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge       = "1"
        max_unavailable = "0"
      }
    }

    template {
      metadata {
        labels = {
          app = "flask"
        }
      }

      spec {
        service_account_name            = "flask-app"
        automount_service_account_token = false
        enable_service_links            = false

        container {
          name              = "flask"
          image             = "team1-flask:latest"
          image_pull_policy = "IfNotPresent"

          env_from {
            secret_ref {
              name = "flask-credentials"
            }
          }

          port {
            container_port = 5000
          }

          liveness_probe {
            exec {
              command = ["curl", "-f", "http://localhost:5000/health"]
            }
            failure_threshold = 3
            period_seconds    = 10
            timeout_seconds   = 5
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true
            run_as_user                = 1000

            capabilities {
              drop = ["ALL"]
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "flask" {
  metadata {
    name      = "flask"
    namespace = "default"
    labels = {
      app = "flask"
    }
    annotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port"   = "5000"
      "prometheus.io/path"   = "/metrics"
    }
  }

  spec {
    selector = {
      app = "flask"
    }

    port {
      name        = "5000"
      port        = 5000
      target_port = 5000
    }
  }
}
