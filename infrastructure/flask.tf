resource "kubernetes_deployment" "flask" {
  metadata {
    name      = "flask"
    namespace = "default"
    labels = {
      app = "flask"
    }
  }

  spec {
    replicas = 2

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
        container {
          name              = "flask"
          image             = "week-2-flask:latest"
          image_pull_policy = "IfNotPresent"

          env_from {
            secret_ref {
              name = "flask-credentials"
            }
          }

          port {
            container_port = 5000
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
        }
      }
    }
  }
}

resource "kubernetes_service" "flask" {
  metadata {
    name      = "flask"
    namespace = "default"
  }

  spec {
    selector = {
      app = "flask"
    }

    port {
      port        = 5000
      target_port = 5000
    }
  }
}
