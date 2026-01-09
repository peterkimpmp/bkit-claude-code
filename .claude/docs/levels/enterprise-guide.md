# Enterprise Level Guide

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
├── apps/                        # Frontend (Turborepo)
│   ├── web/                    # Main web app
│   ├── admin/                  # Admin panel
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
│   ├── 00-requirement/         # Original requirements
│   ├── 01-development/         # Design documents (many)
│   ├── 02-scenario/            # Scenarios, use cases
│   ├── 03-refactoring/         # Analysis and refactoring
│   └── 04-operation/           # Operation documents
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

### Inter-Service Communication

```python
# Synchronous (Internal API)
async def get_user_info(user_id: str) -> dict:
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{USER_SERVICE_URL}/internal/users/{user_id}",
            headers={"X-Internal-Token": INTERNAL_TOKEN}
        )
        return response.json()

# Asynchronous (Message Queue)
await message_queue.publish(
    topic="user.created",
    message={"user_id": user.id, "email": user.email}
)
```

## Domain-Specific CLAUDE.md

### services/CLAUDE.md

```markdown
# Backend Service Conventions

## Architecture
- Follow Clean Architecture 4-Layer
- Dependency: API → Application → Domain ← Infrastructure

## Naming
- Model: CamelCaseModel (e.g., UserModel)
- Schema: CamelCaseRequestModel, CamelCaseResponseModel
- Repository: {Entity}Repository (interface), {Entity}RepositoryImpl (implementation)

## Absolute Rules
- Domain Layer must have no external dependencies
- No hardcoded secrets
- No raw SQL (use SQLAlchemy ORM)
```

### frontend/CLAUDE.md

```markdown
# Frontend Conventions

## Components
- Server Component by default, use 'use client' when needed
- Icons: use lucide-react

## API
- Wrap fetch with tanstack-query
- Use packages/api-client for API client
```

## SoR (Single Source of Truth) Priority

```
1st Priority: Codebase
  - scripts/init-db.sql (truth for DB schema)
  - services/{service}/app/ (each service implementation)

2nd Priority: CLAUDE.md / Convention documents
  - services/CLAUDE.md
  - frontend/CLAUDE.md
  - infra/CLAUDE.md

3rd Priority: docs/ design documents
  - For understanding design intent
  - If code differs, code is correct
```

## Environment Configuration

| Environment | Infrastructure | Deployment Method |
|-------------|----------------|-------------------|
| Local | Docker Compose | Manual |
| Staging | EKS | ArgoCD Auto Sync |
| Production | EKS | ArgoCD Manual Sync |

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

## Security Rules

```
✅ Allowed
- Retrieve secrets from Secrets Manager
- IAM role-based access
- VPC internal communication
- mTLS (inter-service)

❌ Forbidden
- Hardcoded secrets
- DB in public subnet
- Root account usage
- Excessive IAM permissions
```

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| Dependency inversion | No Domain → Infra dependency |
| Direct DB access between services | Use Internal API |
| Missing environment variables | Check ConfigMap/Secret |
| Migration conflicts | Check alembic history |
| Deployment failure | Check ArgoCD sync status |

## Getting Started

```bash
# Initialize
/init-enterprise

# Or request directly
"Design an authentication microservice"
```

## Related Documents

- [Enterprise Skill](../../skills/enterprise/SKILL.md)
- [Dynamic Level Guide](./dynamic-guide.md) (previous level)
- [Upgrade Guide](./upgrade-guide.md)
