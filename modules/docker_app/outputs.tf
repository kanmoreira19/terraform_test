output "container_name" {
  description = "Nome do container Docker."
  value       = docker_container.app.name
}

output "container_id" {
  description = "ID do container Docker."
  value       = docker_container.app.id
}

output "ports" {
  description = "Portas mapeadas do container."
  value       = docker_container.app.ports
}
