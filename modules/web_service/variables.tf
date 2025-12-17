variable "container_name" {
  type        = string
  description = "Nome do container Docker para o serviço web (Apache)."
}

variable "internal_port" {
  type        = number
  description = "Porta interna exposta pelo Apache dentro do container (geralmente 80)."
}

variable "external_port" {
  type        = number
  description = "Porta no host onde o serviço web ficará acessível."
}


variable "image_name" {
  type        = string
  description = "Imagem Docker do Apache."
  default     = "httpd:2.4"
}

variable "env_vars" {
  type        = map(string)
  description = "Variáveis de ambiente opcionais para o container Apache."
  default     = {}
}

variable "content_dir" {
  type        = string
  description = "Diretório local com arquivos HTML/PHP para montar em /var/www/html. Use null para não montar."
  default     = null
}

variable "restart_policy" {
  type        = string
  description = "Política de restart do container (ex: no-failure, always)."
  default     = "no"
}
