variable "azure_location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "demo-swf-app-chris"
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "container_apps_subnet_cidr" {
  description = "CIDR for Container Apps Environment subnet (minimum /23 required by Azure)"
  type        = string
  default     = "10.0.0.0/23"
}

variable "database_subnet_cidr" {
  description = "CIDR for PostgreSQL Flexible Server delegated subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "default_subnet_cidr" {
  description = "CIDR for default/utility subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "postgres"
}

variable "db_username" {
  description = "PostgreSQL administrator username (Azure forbids 'postgres' as admin name)"
  type        = string
  default     = "psqladmin"
}

variable "db_sku_name" {
  description = "SKU name for PostgreSQL Flexible Server"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "db_storage_mb" {
  description = "Storage size in MB for PostgreSQL Flexible Server"
  type        = number
  default     = 32768
}

variable "db_version" {
  description = "PostgreSQL major version"
  type        = string
  default     = "16"
}

variable "container_cpu" {
  description = "CPU cores for container (0.25 = 256 millicores)"
  type        = number
  default     = 0.25
}

variable "container_memory" {
  description = "Memory for container (0.5Gi = 512MB)"
  type        = string
  default     = "0.5Gi"
}

variable "container_min_replicas" {
  description = "Minimum number of container replicas"
  type        = number
  default     = 2
}

variable "container_max_replicas" {
  description = "Maximum number of container replicas"
  type        = number
  default     = 6
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Health check path for the container"
  type        = string
  default     = "/api/soldier/home"
}

variable "acr_sku" {
  description = "SKU for Azure Container Registry"
  type        = string
  default     = "Basic"
}

variable "log_retention_days" {
  description = "Log Analytics workspace retention in days"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "demo-swf-app-chris"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
