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
docker build -t <registry>/demo-swf-app-chris:latest .

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
- `app-manifests/` - Namespace and Deployment/Service YAML
- `postgresql/helm/` - Bitnami PostgreSQL chart values and template generator
- `Dockerfile` - Multi-stage build producing uber JAR with `SPRING_PROFILES_ACTIVE=prod`

## Database Schema
```sql
CREATE TABLE soldier (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  rank VARCHAR(255)
);
```
