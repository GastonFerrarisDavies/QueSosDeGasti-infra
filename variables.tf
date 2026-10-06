# ---- Infraestructura ----

variable "project_name" {
  description = "Prefijo de los recursos de Azure."
  type        = string
  default     = "quesosdegasti"
}

variable "location" {
  description = "Región de Azure."
  type        = string
  default     = "eastus"
}

variable "vm_size" {
  description = "Tamaño de la VM (F1als v7: 1 vCPU, 2 GiB, solo Gen2/NVMe). Standard_A1_v2 no tiene capacidad en eastus2."
  type        = string
  default     = "Standard_F1als_v7"
}

variable "dns_label" {
  description = "Etiqueta DNS de la IP pública: <dns_label>.<location>.cloudapp.azure.com. Única por región."
  type        = string
  default     = "quesosdegasti"
}

variable "admin_username" {
  description = "Usuario SSH de la VM."
  type        = string
  default     = "gasti"
}

variable "ssh_public_key" {
  description = "Clave pública SSH (contenido de ~/.ssh/id_ed25519.pub)."
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "Origen permitido para SSH (p. ej. 203.0.113.10/32). \"*\" abre a todo internet."
  type        = string
  default     = "*"
}

# ---- Aplicación ----

variable "postgres_user" {
  type    = string
  default = "gasti"
}

variable "postgres_db" {
  type    = string
  default = "quesosdegasti"
}

variable "postgres_password" {
  description = "Contraseña de Postgres. Solo letras y números: se embebe en DATABASE_URL."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[A-Za-z0-9]{16,}$", var.postgres_password))
    error_message = "postgres_password debe tener al menos 16 caracteres alfanuméricos."
  }
}

variable "openai_api_key" {
  type      = string
  sensitive = true
}

variable "embedding_model" {
  type    = string
  default = "text-embedding-3-small"
}

variable "embedding_dimensions" {
  description = "Debe coincidir con vector(N) en files/init.sql."
  type        = number
  default     = 1536
}

# ---- Imágenes (images.auto.tfvars, las actualiza el CI) ----

variable "db_image" {
  description = "Imagen de Postgres + pgvector, fijada por digest."
  type        = string
}

variable "api_image" {
  description = "Imagen del backend (repo@sha256:...). Vacía = todavía no se publicó."
  type        = string
  default     = ""
}

variable "frontend_image" {
  description = "Imagen del frontend (repo@sha256:...). Vacía = todavía no se publicó."
  type        = string
  default     = ""
}

# ---- Registro privado (opcional) ----

variable "ghcr_username" {
  description = "Solo si los paquetes de GHCR son privados."
  type        = string
  default     = ""
}

variable "ghcr_token" {
  description = "PAT con read:packages. Solo si los paquetes de GHCR son privados."
  type        = string
  default     = ""
  sensitive   = true
}

variable "deploy_revision" {
  description = "Cambiar este valor fuerza a re-ejecutar el despliegue en la VM aunque nada más cambie."
  type        = string
  default     = ""
}
