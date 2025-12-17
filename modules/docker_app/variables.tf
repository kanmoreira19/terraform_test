variable "container_name" {
  type        = string
  description = "Nome do container Docker."
}

variable "image_name" {
  type        = string
  description = "Nome da imagem Docker (ex: nginx:latest)."
}

variable "internal_port" {
  type        = number
  description = "Porta interna do container."
}

variable "external_port" {
  type        = number
  description = "Porta exposta no host."
}

variable "env_vars" {
  type        = map(string)
  description = "Variáveis de ambiente para o container."
  default     = {}
}
