# Resource Group
output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = azurerm_resource_group.main.id
}

# ACR
output "acr_login_server" {
  description = "Azure Container Registry login server URL"
  value       = azurerm_container_registry.main.login_server
}

output "acr_name" {
  description = "Azure Container Registry name"
  value       = azurerm_container_registry.main.name
}

# Database
output "postgresql_fqdn" {
  description = "PostgreSQL Flexible Server FQDN"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "postgresql_server_name" {
  description = "PostgreSQL Flexible Server name"
  value       = azurerm_postgresql_flexible_server.main.name
}

# Container App
output "application_url" {
  description = "Application URL (Container Apps default FQDN)"
  value       = "https://${azurerm_container_app.main.latest_revision_fqdn}"
}

output "container_app_fqdn" {
  description = "Container App FQDN"
  value       = azurerm_container_app.main.latest_revision_fqdn
}

output "container_app_name" {
  description = "Container App name"
  value       = azurerm_container_app.main.name
}

output "container_apps_environment_name" {
  description = "Container Apps Environment name"
  value       = azurerm_container_app_environment.main.name
}

# Network
output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.main.id
}

# Log Analytics
output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.main.id
}

# Deployment Commands
output "acr_login_command" {
  description = "Command to login to ACR"
  value       = "az acr login --name ${azurerm_container_registry.main.name}"
}

output "docker_push_commands" {
  description = "Commands to build and push Docker image"
  value       = <<-EOT
    docker build -t ${var.project_name}:latest ..
    docker tag ${var.project_name}:latest ${azurerm_container_registry.main.login_server}/${var.project_name}:latest
    docker push ${azurerm_container_registry.main.login_server}/${var.project_name}:latest
  EOT
}

output "container_app_update_command" {
  description = "Command to update container app with new image"
  value       = "az containerapp update --name ${azurerm_container_app.main.name} --resource-group ${azurerm_resource_group.main.name} --image ${azurerm_container_registry.main.login_server}/${var.project_name}:latest"
}

output "container_app_logs_command" {
  description = "Command to view container app logs"
  value       = "az containerapp logs show --name ${azurerm_container_app.main.name} --resource-group ${azurerm_resource_group.main.name} --follow"
}

output "health_check_url" {
  description = "Health check URL"
  value       = "https://${azurerm_container_app.main.latest_revision_fqdn}${var.health_check_path}"
}
