# Level Upgrade Guide

## Upgrade Path

```
┌──────────┐      ┌──────────┐      ┌─────────────┐
│ Starter  │ ───▶ │ Dynamic  │ ───▶ │ Enterprise  │
│ (Static) │      │ (BaaS)   │      │ (MSA/K8s)   │
└──────────┘      └──────────┘      └─────────────┘
```

## Starter → Dynamic

### When to Upgrade

If you need any of the following:

```
□ User login/signup
□ Data storage (posts, comments, etc.)
□ User-specific content
□ Real-time features (chat, notifications)
□ API integration
```

### What Changes

#### Added

**Document Structure**
```
docs/
├── 02-design/
│   ├── data-model.md      ⭐ NEW
│   └── api-spec.md        ⭐ NEW
```

**Code Structure**
```
src/
├── lib/
│   └── bkend.ts           ⭐ NEW (BaaS client)
├── hooks/
│   └── useAuth.ts         ⭐ NEW (auth hook)
└── stores/
    └── auth-store.ts      ⭐ NEW (state management)
```

**Config Files**
```
.mcp.json                   ⭐ NEW (MCP server config)
.env.local                  ⭐ NEW (environment variables)
```

#### Preserved

- Existing components
- Existing styles
- Existing page structure
- Existing documents

### How to Upgrade

```bash
/upgrade-level dynamic
```

Or:
```
"I want to connect with bkend.ai backend"
"Add login functionality"
```

### Migration Checklist

- [ ] Create bkend.ai account
- [ ] Create project and get API key
- [ ] Configure .env.local
- [ ] Configure .mcp.json
- [ ] Write data-model.md
- [ ] Implement auth flow

---

## Dynamic → Enterprise

### When to Upgrade

If you need any of the following:

```
□ Handle large-scale traffic (1M+ requests/month)
□ Need own server/infrastructure control
□ Microservices architecture
□ Complex backend logic
□ Kubernetes usage
□ Multi-environment (staging/production)
□ CI/CD pipeline
□ Team collaboration (multiple developers)
```

### What Changes

#### Added

**Document Structure**
```
docs/
├── 00-requirement/         ⭐ NEW
├── 02-scenario/            ⭐ NEW
└── 04-operation/           ⭐ NEW
    ├── runbook.md          ⭐ NEW
    └── changelog.md        ⭐ NEW
```

**Domain-Specific CLAUDE.md**
```
services/CLAUDE.md          ⭐ NEW (backend conventions)
frontend/CLAUDE.md          ⭐ NEW (frontend conventions)
infra/CLAUDE.md             ⭐ NEW (infra conventions)
```

**Code Structure**
```
services/                   ⭐ NEW
├── auth/                  (auth service)
├── user/                  (user service)
└── shared/                (shared modules)

infra/                      ⭐ NEW
├── terraform/             (IaC)
└── k8s/                   (Kubernetes manifests)
```

**CI/CD**
```
.github/workflows/          ⭐ NEW
├── ci.yml
├── cd-staging.yml
└── cd-production.yml
```

#### What Changes

- Frontend → Monorepo (Turborepo)
- Single backend → Microservices
- BaaS → Own server

### How to Upgrade

```bash
/upgrade-level enterprise
```

Or:
```
"I want to split into microservices"
"Set up Kubernetes deployment"
```

### Migration Checklist

- [ ] Architecture design (which services to split?)
- [ ] Data migration plan
- [ ] Infrastructure setup (AWS/GCP)
- [ ] Create Kubernetes cluster
- [ ] Set up CI/CD pipeline
- [ ] Write domain-specific CLAUDE.md
- [ ] Team onboarding documentation

---

## Upgrade Considerations

### Gradual Transition

Don't change everything at once.

```
❌ Bad Example:
Day 1: Change entire architecture

✅ Good Example:
Week 1: Infrastructure setup
Week 2: Split auth service
Week 3: Split user service
...
```

### Data Migration

```
1. Build new system (read-only)
2. Set up data synchronization
3. Test writes on new system
4. Gradually migrate traffic
5. Shutdown old system
```

### Rollback Plan

Always maintain rollback capability:

```
□ Keep old system running (minimum 2 weeks)
□ Data backup
□ Quick DNS switch capability
□ Use feature flags
```

---

## FAQ

### Q: Must I upgrade in order?

A: No, you can skip levels based on your needs.
   - Complex system from start → Start with Enterprise
   - Simple app → Starter is enough

### Q: Is downgrading possible?

A: Technically possible but not recommended.
   If needed, start a new project.

### Q: What are the upgrade costs?

A: Infrastructure costs by level:
   - Starter: Free (Vercel Free)
   - Dynamic: $10-50/month (bkend.ai)
   - Enterprise: $100-1000+/month (AWS)

### Q: Recommended level by team size?

A:
   - 1 person: Starter → Dynamic
   - 2-5 people: Dynamic → Enterprise
   - 5+ people: Enterprise

---

## Related Documents

- [Starter Guide](./starter-guide.md)
- [Dynamic Guide](./dynamic-guide.md)
- [Enterprise Guide](./enterprise-guide.md)
