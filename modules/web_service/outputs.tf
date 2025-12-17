output "container_id" {
  description = "ID do container Apache."
  value       = docker_container.apache.id
}

output "container_name" {
  description = "Nome do container Apache."
  value       = docker_container.apache.name
}

output "service_url" {
  description = "URL HTTP de acesso ao serviço web no host."
  value       = "http://localhost:${var.external_port}"
}
