# Azure Configuration
azure_location = "eastus2"
project_name   = "demo-swf-app-chris"

# VNet Configuration
vnet_address_space         = "10.0.0.0/16"
container_apps_subnet_cidr = "10.0.0.0/23"
database_subnet_cidr       = "10.0.2.0/24"
default_subnet_cidr        = "10.0.3.0/24"

# Database Configuration
db_name       = "postgres"
db_username   = "psqladmin"
db_sku_name   = "B_Standard_B1ms"
db_storage_mb = 32768
db_version    = "16"

# Container Configuration
container_cpu          = 0.25
container_memory       = "0.5Gi"
container_min_replicas = 2
container_max_replicas = 6
container_port         = 8080
health_check_path      = "/api/soldier/home"

# ACR Configuration
acr_sku = "Basic"

# Logging
log_retention_days = 30

# Tags
tags = {
  Project     = "demo-swf-app-chris"
  Environment = "production"
  ManagedBy   = "terraform"
}
