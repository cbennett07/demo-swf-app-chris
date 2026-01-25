# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

# ECR Outputs
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.app.name
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS cluster endpoint"
  value       = aws_rds_cluster.main.endpoint
}

output "rds_reader_endpoint" {
  description = "RDS cluster reader endpoint"
  value       = aws_rds_cluster.main.reader_endpoint
}

output "db_credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret containing DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

# ECS Outputs
output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}

# ALB Outputs
output "alb_dns_name" {
  description = "ALB DNS name - use this for Cloudflare DNS"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID"
  value       = aws_lb.main.zone_id
}

# ACM Outputs
output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate.main.arn
}

output "acm_certificate_status" {
  description = "ACM certificate status"
  value       = aws_acm_certificate.main.status
}

output "acm_validation_records" {
  description = "DNS records to add to Cloudflare for ACM certificate validation"
  value = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
}

# Deployment Info
output "application_url" {
  description = "Application URL"
  value       = "https://${var.domain_name}"
}

output "health_check_url" {
  description = "Health check URL"
  value       = "https://${var.domain_name}${var.health_check_path}"
}

# Useful Commands
output "docker_login_command" {
  description = "Command to login to ECR"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.app.repository_url}"
}

output "docker_push_commands" {
  description = "Commands to build and push Docker image"
  value = <<-EOT
    docker build -t ${var.project_name}:latest .
    docker tag ${var.project_name}:latest ${aws_ecr_repository.app.repository_url}:latest
    docker push ${aws_ecr_repository.app.repository_url}:latest
  EOT
}

output "ecs_update_service_command" {
  description = "Command to force new deployment"
  value       = "aws ecs update-service --cluster ${aws_ecs_cluster.main.name} --service ${aws_ecs_service.app.name} --force-new-deployment --region ${var.aws_region}"
}

output "cloudflare_dns_instructions" {
  description = "Instructions for Cloudflare DNS setup"
  value = <<-EOT

    =====================================
    CLOUDFLARE DNS CONFIGURATION
    =====================================

    1. Add ACM certificate validation CNAME record (check acm_validation_records output)

    2. After certificate is validated, add the following DNS record:
       Type: CNAME
       Name: @ (or cb-dso.dev)
       Target: ${aws_lb.main.dns_name}
       Proxy status: DNS only (grey cloud) - IMPORTANT!

    Note: Keep proxy status OFF (grey cloud) to allow AWS ALB to handle SSL

  EOT
}
