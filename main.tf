terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.6"
    }
  }
}

provider "docker" {}

locals {
  app_name    = "hexxa-app"
  app_version = "1.0.0"
}

module "docker_app" {
  source = "./modules/docker_app"
  container_name = "${local.app_name}-${local.app_version}"
  image_name     = "nginx:1.28"
  internal_port  = 80
  external_port  = 8001
  env_vars = {
    APP_ENV = "dev"
  }
}

module "web_apache" {
  source = "./modules/web_service_apache"

  container_name = "hexxa-apache"
  internal_port  = 80
  external_port  = 8080

  env_vars = {
    APP_ENV = "dev"
  }

  content_dir = "/opt/www/meu-site" 
}