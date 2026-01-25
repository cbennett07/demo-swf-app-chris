# AWS Configuration
aws_region   = "us-east-1"
project_name = "demo-swf-app-chris"
domain_name  = "cb-dso.dev"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"

# Database Configuration
db_name         = "postgres"
db_username     = "postgres"
db_min_capacity = 0.5
db_max_capacity = 2

# ECS Configuration
ecs_task_cpu      = 256
ecs_task_memory   = 512
ecs_desired_count = 2
container_port    = 8080
health_check_path = "/api/soldier/home"

# Tags
tags = {
  Project     = "demo-swf-app-chris"
  Environment = "production"
  ManagedBy   = "terraform"
}
