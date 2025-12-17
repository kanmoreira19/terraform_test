variable "docker_host" {
  type        = string
  description = "Host do Docker, se for remoto (opcional)."
  default     = "unix:///var/run/docker.sock"
}