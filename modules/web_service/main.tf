terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

locals {
  default_labels = {
    managed_by = "terraform"
    service    = "apache2"
  }
}

resource "docker_image" "apache" {
  name = var.image_name
}

resource "docker_container" "apache" {
  name  = var.container_name
  image = docker_image.apache.name

  env = [
    for k, v in var.env_vars : "${k}=${v}"
  ]

  ports {
    internal = var.internal_port
    external = var.external_port
  }

  dynamic "volumes" {
    for_each = var.content_dir == null ? [] : [var.content_dir]
    content {
      host_path      = volumes.value
      container_path = "/var/www/html"
      read_only      = false
    }
  }

  restart = var.restart_policy
}