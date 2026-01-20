---
name: enterprise
description: |
  Enterprise-grade system development with microservices, Kubernetes, and Terraform.
  Handles high traffic, high availability, and complex architecture requirements.

  Use proactively when user needs high traffic, microservices, or custom infrastructure.

  Triggers: microservices, kubernetes, terraform, k8s, AWS, 마이크로서비스, マイクロサービス, 微服务

  Do NOT use for: simple websites, MVPs, or projects without infrastructure requirements.
agent: infra-architect
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
user-invocable: false
---

# Advanced (Enterprise) Skill

## Target Audience

- Senior developers
- CTOs / Architects
- Large-scale system operators

## Tech Stack

```
Frontend:
- Next.js 14+ (Turborepo monorepo)
- TypeScript
- Tailwind CSS
- TanStack Query
- Zustand

Backend:
- Python FastAPI (microservices)
- PostgreSQL (schema separation)
- Redis (cache, Pub/Sub)
- RabbitMQ / SQS (message queue)

Infrastructure:
- AWS (EKS, RDS, S3, CloudFront)
- Kubernetes (Kustomize)
- Terraform (IaC)
- ArgoCD (GitOps)

CI/CD:
- GitHub Actions
- Docker
```

## Project Structure

```
project/
├── apps/                        # Frontend apps (Turborepo)
│   ├── web/                    # Main web app
│   ├── admin/                  # Admin
│   └── docs/                   # Documentation site
│
├── packages/                    # Shared packages
│   ├── ui/                     # UI components
│   ├── api-client/             # API client
│   └── config/                 # Shared config
│
├── services/                    # Backend microservices
│   ├── auth/                   # Auth service
│   ├── user/                   # User service
│   ├── {domain}/               # Domain-specific services
│   └── shared/                 # Shared modules
│
├── infra/                       # Infrastructure code
│   ├── terraform/
│   │   ├── modules/            # Reusable modules
│   │   └── environments/       # Environment-specific config
│   └── k8s/
│       ├── base/               # Common manifests
│       └── overlays/           # Environment-specific patches
│
├── docs/                        # PDCA documents
│   ├── 00-requirement/
│   ├── 01-development/         # Design documents (multiple)
│   ├── 02-scenario/
│   ├── 03-refactoring/
│   └── 04-operation/
│
├── scripts/                     # Utility scripts
├── .github/workflows/           # CI/CD
├── docker-compose.yml
├── turbo.json
└── pnpm-workspace.yaml
```

## Clean Architecture (4-Layer)

```
┌─────────────────────────────────────────────────────────┐
│                    API Layer                             │
│  - FastAPI routers                                       │
│  - Request/Response DTOs                                 │
│  - Auth/authz middleware                                 │
├─────────────────────────────────────────────────────────┤
│                  Application Layer                       │
│  - Service classes                                       │
│  - Use Case implementation                               │
│  - Transaction management                                │
├─────────────────────────────────────────────────────────┤
│                    Domain Layer                          │
│  - Entity classes (pure Python)                          │
│  - Repository interfaces (ABC)                           │
│  - Business rules                                        │
├─────────────────────────────────────────────────────────┤
│                 Infrastructure Layer                     │
│  - Repository implementations (SQLAlchemy)               │
│  - External API clients                                  │
│  - Cache, messaging                                      │
└─────────────────────────────────────────────────────────┘

Dependency direction: Top → Bottom
Domain Layer depends on nothing
```

## Core Patterns

### Repository Pattern

```python
# domain/repositories/user_repository.py (interface)
from abc import ABC, abstractmethod

class UserRepository(ABC):
    @abstractmethod
    async def find_by_id(self, id: str) -> User | None:
        pass

    @abstractmethod
    async def save(self, user: User) -> User:
        pass

# infrastructure/repositories/user_repository_impl.py (implementation)
class UserRepositoryImpl(UserRepository):
    def __init__(self, db: AsyncSession):
        self.db = db

    async def find_by_id(self, id: str) -> User | None:
        result = await self.db.execute(
            select(UserModel).where(UserModel.id == id)
        )
        return result.scalar_one_or_none()
```

### Inter-service Communication

```python
# Synchronous (Internal API)
async def get_user_info(user_id: str) -> dict:
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{USER_SERVICE_URL}/internal/users/{user_id}",
            headers={"X-Internal-Token": INTERNAL_TOKEN}
        )
        return response.json()

# Asynchronous (message queue)
await message_queue.publish(
    topic="user.created",
    message={"user_id": user.id, "email": user.email}
)
```

### Terraform Module

```hcl
# modules/eks/main.tf
resource "aws_eks_cluster" "this" {
  name     = "${var.environment}-${var.project_name}-eks"
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  tags = merge(var.tags, {
    Environment = var.environment
  })
}
```

### Kubernetes Deployment

```yaml
# k8s/base/backend/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  replicas: 2
  template:
    spec:
      containers:
        - name: user-service
          image: ${ECR_REGISTRY}/user-service:${TAG}
          resources:
            requests:
              cpu: "100m"
              memory: "256Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
          livenessProbe:
            httpGet:
              path: /health
              port: 8000
```

## Environment Configuration

| Environment | Infrastructure | Deployment Method |
|-------------|---------------|-------------------|
| Local | Docker Compose | Manual |
| Staging | EKS | ArgoCD Auto Sync |
| Production | EKS | ArgoCD Manual Sync |

## Security Rules

```
✅ Allowed
- Retrieve secrets from Secrets Manager
- IAM role-based access
- VPC internal communication
- mTLS (inter-service)

❌ Prohibited
- Hardcoded secrets
- DB in public subnet
- Using root account
- Excessive IAM permissions
```

## CI/CD Pipeline

```
Push to feature/*
    ↓
GitHub Actions (CI)
    - Lint
    - Test
    - Build Docker image
    - Push to ECR
    ↓
PR to staging
    ↓
ArgoCD Auto Sync (Staging)
    ↓
PR to main
    ↓
ArgoCD Manual Sync (Production)
```

## SoR Priority

```
1st Priority: Codebase
  - scripts/init-db.sql (source of truth for DB schema)
  - services/{service}/app/ (each service implementation)

2nd Priority: CLAUDE.md / Convention docs
  - services/CLAUDE.md
  - frontend/CLAUDE.md
  - infra/CLAUDE.md

3rd Priority: docs/ design documents
  - For understanding design intent
  - If different from code, code is correct
```
