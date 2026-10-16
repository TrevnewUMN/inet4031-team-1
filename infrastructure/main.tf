terraform {
  required_version = ">= 1.0"

  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    kubernetes = {
      source  = "opentofu/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
