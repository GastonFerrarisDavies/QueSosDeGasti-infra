locals {
  # Hasta que ambos CI publiquen su primera imagen solo se crea la infraestructura.
  images_ready = var.api_image != "" && var.frontend_image != ""

  allowed_origins = join(",", [
    "http://${azurerm_public_ip.main.fqdn}",
    "http://${azurerm_public_ip.main.ip_address}",
  ])
}

# Escribe docker-compose.yml + .env en la VM y hace `docker compose up`.
# Cualquier cambio en el script (un digest nuevo, otra variable, el compose)
# actualiza el recurso, y Azure re-ejecuta el script en la VM sin recrearla.
resource "azurerm_virtual_machine_run_command" "deploy" {
  count = local.images_ready ? 1 : 0

  name               = "deploy-app"
  location           = azurerm_resource_group.main.location
  virtual_machine_id = azurerm_linux_virtual_machine.main.id

  source {
    script = templatefile("${path.module}/templates/deploy.sh.tftpl", {
      compose              = file("${path.module}/templates/docker-compose.yml")
      init_sql             = file("${path.module}/files/init.sql")
      db_image             = var.db_image
      api_image            = var.api_image
      frontend_image       = var.frontend_image
      postgres_user        = var.postgres_user
      postgres_db          = var.postgres_db
      allowed_origins      = local.allowed_origins
      embedding_model      = var.embedding_model
      embedding_dimensions = var.embedding_dimensions
      deploy_revision      = var.deploy_revision
    })
  }

  # Los secretos van como parámetros protegidos (llegan al script como variables
  # de entorno) para no ocultar el diff del script en el plan.
  protected_parameter {
    name  = "POSTGRES_PASSWORD"
    value = var.postgres_password
  }

  protected_parameter {
    name  = "OPENAI_API_KEY"
    value = var.openai_api_key
  }

  dynamic "protected_parameter" {
    for_each = var.ghcr_username != "" ? [1] : []
    content {
      name  = "GHCR_USERNAME"
      value = var.ghcr_username
    }
  }

  dynamic "protected_parameter" {
    for_each = var.ghcr_username != "" ? [1] : []
    content {
      name  = "GHCR_TOKEN"
      value = var.ghcr_token
    }
  }

  timeouts {
    create = "30m"
    update = "30m"
  }
}
