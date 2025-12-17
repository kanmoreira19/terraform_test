output "docker_container_name" {
  description = "Nome do container criado pelo módulo."
  value       = module.docker_app.container_name
}

output "docker_container_id" {
  description = "ID do container criado pelo módulo."
  value       = module.docker_app.container_id
}

output "docker_container_ports" {
  description = "Portas expostas pelo container."
  value       = module.docker_app.ports
}

output "apache_url" {
  value       = module.web_apache.service_url
  description = "URL do serviço Apache provisionado."
}