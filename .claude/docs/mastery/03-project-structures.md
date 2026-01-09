# 3. Project Structure Guide

> This document is part of [CLAUDE-CODE-MASTERY.md](../CLAUDE-CODE-MASTERY.md).

---

## 3.1 Project Structure Detection

| Structure | Detection Method |
|-----------|------------------|
| Monorepo | `pnpm-workspace.yaml`, `turbo.json`, `lerna.json`, `nx.json` |
| Microservices | `docker-compose.yml` + multiple service folders |
| Single App | Single `package.json` or config file |
| Library | `lib/`, `src/` structure + publish config |
| Fullstack | `frontend/`, `backend/` or `client/`, `server/` |

---

## 3.2 Monorepo

**Characteristics**: Multiple packages in one repository

**Recommended Configuration**:

```markdown
<!-- CLAUDE.md -->
# Monorepo Development Workflow

## Package Management
- pnpm workspace / npm workspaces / yarn workspaces
- `pnpm --filter {package} {command}` format

## Development Order
pnpm -r typecheck        # Type check all
pnpm --filter {pkg} test # Test per package
pnpm -r build            # Build all

## Structure
packages/
├── core/          # Common utilities
├── ui/            # UI components
├── api/           # API client
└── app/           # Main app
```

**Recommended Skills**:
- `{project}-core`: Common layer
- `{project}-{domain}`: Per domain

---

## 3.3 Microservices

**Characteristics**: Independent services running in containers

**Recommended Configuration**:

```markdown
<!-- CLAUDE.md -->
# Microservices Development Workflow

## Service Management
- Docker Compose for local development
- Each service builds/deploys independently

## Development Order
docker-compose up -d     # Start services
docker-compose logs -f   # Check logs
docker-compose down      # Stop services

## Structure
services/
├── auth/          # Auth service
├── user/          # User service
├── order/         # Order service
└── gateway/       # API Gateway
```

**Recommended Skills**:
- `{project}-architecture`: Overall architecture
- `{project}-{service}`: Per service

---

## 3.4 Single App

**Characteristics**: One application

**Recommended Configuration**:

```markdown
<!-- CLAUDE.md -->
# Development Workflow

## Structure
src/
├── components/    # UI components
├── hooks/         # Custom hooks
├── lib/           # Utilities
├── pages/         # Pages (or routes/)
└── styles/        # Styles
```

**Start with Minimal Settings**:
- CLAUDE.md
- settings.local.json (hooks)
- 2-3 commands

---

## 3.5 Fullstack App

**Characteristics**: Frontend + Backend together

**Recommended Configuration**:

```markdown
<!-- CLAUDE.md -->
# Fullstack Development Workflow

## Structure
frontend/          # React/Vue/Angular
├── src/
└── package.json

backend/           # Node/Python/Go
├── src/
└── package.json (or language-specific config)

## Development Order
# Backend first
cd backend && npm run dev

# Frontend
cd frontend && npm run dev
```

**Recommended Skills**:
- `{project}-frontend`: Frontend rules
- `{project}-backend`: Backend rules
- `{project}-api`: API contract
