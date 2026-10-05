output "public_ip" {
  value = azurerm_public_ip.main.ip_address
}

output "fqdn" {
  value = azurerm_public_ip.main.fqdn
}

output "frontend_url" {
  value = "http://${azurerm_public_ip.main.fqdn}"
}

# Valor de la variable NEXT_PUBLIC_API_URL del repo del frontend.
output "api_url" {
  value = "http://${azurerm_public_ip.main.fqdn}:8080"
}

output "ssh_command" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.main.fqdn}"
}

output "app_deployed" {
  value = local.images_ready
}
