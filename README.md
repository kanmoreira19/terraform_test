# Terraform Docker Web Stack

[![Terraform](https://img.shields.io/badge/Terraform-%235835CC?style=for-the-badge&logo=terraform&logoColor=white)](https://developer.hashicorp.com/terraform)  
[![Docker](https://img.shields.io/badge/Docker-0db7ed?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)  
[![markdownlint](https://img.shields.io/badge/markdownlint-enabled-success?style=for-the-badge)](https://github.com/DavidAnson/markdownlint) [web:127][web:136][web:122]

Infraestrutura em Terraform para provisionar dois serviços web em Docker local:

- Um container **Nginx** (app genérico) usando o módulo `docker_app`.
- Um container **Apache2** (serviço web) usando o módulo `web_service`.  

Toda a configuração segue boas práticas de módulos Terraform, versionamento de providers e padronização de Markdown com markdownlint. [web:134][web:140][web:123]

---

## Arquitetura

### Visão lógica

- **Raiz do projeto**
  - Define o provider `kreuzwerker/docker` (versão `~> 3.6`).
  - Define `locals` compartilhando nomes/versões.
  - Instancia:
    - `module "docker_app"` → Nginx.
    - `module "web_apache"` → Apache2. [web:112][web:116]

- **Módulo `modules/docker_app`**
  - Cria uma `docker_image` e um `docker_container` para Nginx.
  - Totalmente configurável via variáveis (porta, imagem, envs). [web:112][web:115]

- **Módulo `modules/web_service`**
  - Cria uma `docker_image` e um `docker_container` para Apache2.
  - Permite montar diretório de conteúdo local em `/var/www/html`. [web:118][web:120]

### Estrutura de diretórios

.  
├── main.tf  
├── outputs.tf  
├── variables.tf # opcional  
├── .markdownlint.json # configuração markdownlint  
└── modules  
├── docker_app  
│ ├── main.tf  
│ ├── variables.tf  
│ └── outputs.tf  
└── web_service  
├── main.tf  
├── variables.tf  
└── outputs.tf  


---

## Uso rápido

### Pré‑requisitos

- Docker instalado e rodando localmente.
- Terraform instalado (versão compatível com o provider `kreuzwerker/docker`). [web:116][web:120]
- Opcional: Node.js + `markdownlint-cli` para lint de Markdown. [web:122][web:138]

### Passos

1. Inicializar Terraform
terraform init

2. Ver plano de execução
terraform plan

3. Aplicar mudanças
terraform apply

4. Acessar serviços  
Nginx: http://localhost:8001  
Apache: http://localhost:8080


---

## Configuração do projeto raiz

### `main.tf`

```terraform
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
  app_name        = "hexxa-app"
  app_version     = "1.0.0"

  apache_name     = "hexxa-apache"
  apache_version  = "2.4"
  apache_port     = 8080
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
  source = "./modules/web_service"

  container_name = "${local.apache_name}-${local.apache_version}"
  internal_port  = 80
  external_port  = local.apache_port

  env_vars = {
    APP_ENV = "dev"
  }

  content_dir = "/opt/www/meu-site"
}
```


### `outputs.tf`

```terraform
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
```


---

## Módulo `docker_app` (Nginx)


### `main.tf`

```terraform
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
```

### `variables.tf`

```terraform
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
```


### `outputs.tf`

```terraform
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
```


---

## Módulo `web_service` (Apache2)


### `main.tf`

```terraform
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
```

### `variables.tf`


```terraform
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
```


### `outputs.tf`

```terraform
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
```


---

## Configuração do markdownlint

Crie um arquivo `.markdownlint.json` na raiz:

```markdownlint
{
"default": true,
"MD013": false,
"MD033": false,
"MD041": false
}
```

- `default: true`: habilita todas as regras padrão.
- Regras desabilitadas:
  - `MD013`: comprimento máximo de linha (flexibiliza para código/blocos longos).
  - `MD033`: HTML em Markdown (útil se usar badges complexos).
  - `MD041`: primeira linha precisa ser um heading (caso queira flexibilidade). [web:123][web:129]

### Como rodar o markdownlint

Instalação com npm:

```bash
npm install --save-dev markdownlint-cli
```

Execução:

```bash
npx markdownlint "**/*.md"
```

Ou com `--fix` para corrigir automaticamente problemas simples:

```bash
npx markdownlint --fix "**/*.md"
```

[web:122][web:138]

---

## Boas práticas aplicadas

- **Estrutura organizada de módulos** seguindo recomendações oficiais da HashiCorp. [web:134][web:140]  
- **Versionamento de provider** com `~> 3.6` para garantir compatibilidade de minor/patch. [web:116]  
- **README.md profissional** com badges, arquitetura, uso e exemplos claros. [web:128][web:131]  
- **markdownlint configurado** via `.markdownlint.json` para padronizar documentação Markdown. [web:123][web:124]  

Basta copiar esse README.md, o `.markdownlint.json` e os arquivos `.tf` para o seu repositório que você já tem uma base “enterprise ready” para o módulo/projeto Terraform.
