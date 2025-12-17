terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.6"
    }
  }
}

locals {
  labels = {
    managed_by = "terraform"
    module     = "docker_app"
  }
}

resource "docker_image" "app" {
  name = var.image_name
}

resource "docker_container" "app" {
  name  = var.container_name
  image = docker_image.app.name
 
  env = [
    for k, v in var.env_vars : "${k}=${v}"
  ]

  ports {
    internal = var.internal_port
    external = var.external_port
  }
}
