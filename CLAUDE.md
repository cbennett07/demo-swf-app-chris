# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Full-stack containerized CRUD application demonstrating Software Factory deployment practices. Manages soldier records (name, rank) with a Spring Boot backend, React frontend, and PostgreSQL database, deployed to Kubernetes.

## Build & Run Commands

### Local Development
```bash
# Run backend with integrated frontend (connects to local PostgreSQL)
./gradlew bootRun

# Run frontend dev server separately (for hot reload during UI development)
cd frontend && npm start
```

### Build
```bash
# Full build (builds frontend, copies to backend, creates uber JAR)
./gradlew build

# Frontend only
cd frontend && npm run build
```

### Testing
```bash
# Backend tests
./gradlew test

# Frontend tests
cd frontend && npm test
```

### Docker
```bash
# Build image (multi-stage: builds frontend+backend, outputs production JAR)
# Always use --platform linux/amd64 (dev machine is Apple Silicon, deploy targets are AMD64)
docker build --platform linux/amd64 -t <registry>/demo-swf-app-chris:latest .

# Push to registry
docker push <registry>/demo-swf-app-chris:latest
```

### Kubernetes Deployment
```bash
# Generate PostgreSQL Helm template
./postgresql/helm/generate-manifest.sh

# Deploy in order
kubectl apply -f app-manifests/namespace.yaml
kubectl apply -f postgresql/helm/template/postgresql-template.yaml
kubectl apply -f app-manifests/deployment.yaml

# Port forward for testing
kubectl -n demo-swf-app-chris port-forward svc/demo-swf-app-chris-service 8080:8080
```

## Architecture

### Backend (Spring Boot 3.2.4, Java 17)
- **Package**: `demoswfappchris.demoswfappchris`
- **Entry point**: `DemoSwfAppChrisApplication.java`
- **Layers**:
  - `controller/SoldierController.java` - REST API at `/api/soldier`
  - `model/Soldier.java` - JPA entity (id, name, rank)
  - `repository/SoldierRepository.java` - JpaRepository for CRUD

### REST Endpoints
- `GET /api/soldier/home` - Health check message
- `GET /api/soldier/list` - List all soldiers
- `POST /api/soldier/post` - Create soldier (JSON body: `{name, rank}`)
- `DELETE /api/soldier/delete` - Delete soldiers (JSON body: `[id1, id2, ...]`)

### Frontend (React 18)
- Location: `frontend/src/`
- Main component: `App.js` - Handles form input, table display, checkbox selection
- API calls via axios to `API_BASE_URL` env var or `http://localhost:8080/api/soldier`

### Configuration Profiles
- `application-local.yaml` - Local dev (localhost:5432)
- `application-prod.yaml` - Kubernetes (postgresql.demo-swf-app-chris:5432)
- Profile selected via `SPRING_PROFILES_ACTIVE` (local for bootRun, prod in Docker)

### Build Pipeline (Gradle)
Custom tasks chain: `installFrontend` → `buildFrontend` → `copyFrontend` → backend build
- Frontend gets bundled into `src/main/resources/static` and served by Spring Boot

### Infrastructure
- `app-manifests/` - Namespace and Deployment/Service YAML (Kubernetes)
- `postgresql/helm/` - Bitnami PostgreSQL chart values and template generator
- `terraform/` - AWS Fargate deployment with RDS Aurora PostgreSQL
- `terraform-azure/` - Azure Container Apps deployment with PostgreSQL Flexible Server
- `Dockerfile` - Multi-stage build producing uber JAR with `SPRING_PROFILES_ACTIVE=prod`

### AWS Fargate Deployment (terraform/)
Deploy to AWS Fargate with RDS Aurora PostgreSQL Serverless v2:
```bash
cd terraform
terraform init
terraform plan
terraform apply

# After infrastructure is up, push Docker image
./deploy.sh
```

**Components:**
- VPC with public/private subnets across 2 AZs
- Application Load Balancer with ACM SSL certificate
- ECS Fargate service (2 tasks, auto-scaling)
- RDS Aurora PostgreSQL Serverless v2
- ECR repository for Docker images

**Post-deployment:**
1. Add ACM validation CNAME to Cloudflare (see `terraform output acm_validation_records`)
2. Add CNAME pointing domain to ALB (see `terraform output alb_dns_name`)
3. Set Cloudflare proxy to DNS-only (grey cloud) for SSL to work

### Azure Container Apps Deployment (terraform-azure/)
Deploy to Azure Container Apps with PostgreSQL Flexible Server:
```bash
cd terraform-azure
./deploy.sh
```

Or manually:
```bash
cd terraform-azure
terraform init
terraform plan
terraform apply

# After infrastructure is up, build and push Docker image
cd ..
docker build --platform linux/amd64 -t demo-swf-app-chris:latest .
az acr login --name $(cd terraform-azure && terraform output -raw acr_name)
docker tag demo-swf-app-chris:latest $(cd terraform-azure && terraform output -raw acr_login_server)/demo-swf-app-chris:latest
docker push $(cd terraform-azure && terraform output -raw acr_login_server)/demo-swf-app-chris:latest

# Update container app with new image
az containerapp update \
  --name demo-swf-app-chris \
  --resource-group demo-swf-app-chris-rg \
  --image $(cd terraform-azure && terraform output -raw acr_login_server)/demo-swf-app-chris:latest
```

**Components:**
- VNet with Container Apps, database, and default subnets
- Azure Container Apps Environment with built-in HTTPS ingress
- Azure Container App (0.25 vCPU, 0.5Gi, 2-6 replicas with HTTP auto-scaling)
- Azure Database for PostgreSQL Flexible Server (Burstable B1ms, v16)
- Azure Container Registry (Basic SKU)
- Log Analytics Workspace

**Notes:**
- No custom domain — uses default `*.azurecontainerapps.io` URL
- DB admin username is `psqladmin` (Azure forbids `postgres` as admin name)
- DB password auto-generated and passed to container as a secret
- App URL available via `terraform output application_url`

## Deployment Notes & Gotchas

### Container Platform (AMD64)
- Dev machine is Apple Silicon (ARM64), but all deploy targets (AWS Fargate, Azure Container Apps, Kubernetes) run AMD64
- **Always** use `--platform linux/amd64` when building Docker images for deployment
- Omitting this flag produces ARM images that fail silently or crash on deploy targets

### AWS Fargate (Cloudflare DNS)
- ACM certificate uses DNS validation — `terraform apply` will **block** until the CNAME is added to Cloudflare
- Cloudflare CNAME gotchas:
  - **Name field**: Only enter the subdomain part (e.g., `_d0041d1d4c...`), Cloudflare auto-appends the domain
  - **Target field**: Remove the trailing dot (e.g., use `...acm-validations.aws` not `...acm-validations.aws.`)
  - **Proxy status**: Must be "DNS only" (grey cloud) for both the ACM validation CNAME and the domain CNAME pointing to the ALB — AWS ALB handles SSL termination
- ECS service is created by Terraform before any image exists in ECR, so initial tasks will fail with `CannotPullContainerError` — this is expected; push the image and run `aws ecs update-service --force-new-deployment` to resolve
- After apply, two Cloudflare DNS records are needed:
  1. ACM validation CNAME (from `terraform output acm_validation_records`)
  2. Root CNAME (`@`) pointing to ALB (from `terraform output alb_dns_name`)

### Azure Container Apps
- Azure forbids `postgres` as DB admin username — use `psqladmin` instead
- DB password is auto-generated by Terraform and passed as a container secret
- No custom domain configured — uses default `*.azurecontainerapps.io` URL

## Database Schema
```sql
CREATE TABLE soldier (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  rank VARCHAR(255)
);
```
