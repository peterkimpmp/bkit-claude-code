---
name: phase-2-convention
description: |
  Skill for defining coding rules and conventions.
  Ensures consistent code style and specifies coding standards for AI collaboration.

  Triggers: convention, coding style, naming rules, 컨벤션, コンベンション, 编码风格
agent: pipeline-guide
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
user-invocable: false
---

# Phase 2: Coding Convention

> Define code writing rules

## Purpose

Maintain consistent code style. Especially important when collaborating with AI - clarify what style AI should use when writing code.

## What to Do in This Phase

1. **Naming Rules**: Variables, functions, files, folder names
2. **Code Style**: Indentation, quotes, semicolons, etc.
3. **Structure Rules**: Folder structure, file separation criteria
4. **Pattern Definition**: Frequently used code patterns

## Deliverables

```
Project Root/
├── CONVENTIONS.md          # Full conventions
└── docs/01-plan/
    ├── naming.md           # Naming rules
    └── structure.md        # Structure rules
```

## Core Convention Items

### Naming
- Components: PascalCase
- Functions: camelCase
- Constants: UPPER_SNAKE_CASE
- Files: kebab-case or PascalCase

### Folder Structure
```
src/
├── components/     # Reusable components
├── features/       # Feature modules
├── hooks/          # Custom hooks
├── utils/          # Utilities
└── types/          # Type definitions
```

## Environment Variable Convention

### Naming Rules

| Prefix | Purpose | Exposure Scope |
|--------|---------|----------------|
| `NEXT_PUBLIC_` | Client-exposed | Browser |
| `DB_` | Database | Server only |
| `API_` | External API keys | Server only |
| `AUTH_` | Authentication | Server only |
| `SMTP_` | Email service | Server only |

### .env File Structure

```
Project Root/
├── .env.example        # Template (in Git)
├── .env.local          # Local development (Git ignored)
├── .env.development    # Development defaults
├── .env.production     # Production defaults
```

### Environment Variable Validation

```typescript
// lib/env.ts
import { z } from 'zod';

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  AUTH_SECRET: z.string().min(32),
  NODE_ENV: z.enum(['development', 'staging', 'production']).default('development'),
  NEXT_PUBLIC_APP_URL: z.string().url(),
});

export const env = envSchema.parse(process.env);
```

## Clean Architecture Principles

### 4-Layer Architecture

```
src/
├── presentation/        # UI components, pages, hooks
├── application/         # Business use cases, services
├── domain/              # Entities, types, constants
└── infrastructure/      # API clients, database, external services
```

### Layer Responsibilities

| Layer | Can Depend On | Cannot Depend On |
|-------|---------------|------------------|
| **Presentation** | Application, Domain | Infrastructure directly |
| **Application** | Domain, Infrastructure | Presentation |
| **Domain** | Nothing (independent) | All external layers |
| **Infrastructure** | Domain | Application, Presentation |

### Dependency Rule

```typescript
// ❌ Bad: Presentation directly calls Infrastructure
import { apiClient } from '@/lib/api/client';

// ✅ Good: Presentation → Application → Infrastructure
import { useUsers } from '@/hooks/useUsers';  // Hook calls Service
```

### Level-wise Application

| Level | Architecture |
|-------|-------------|
| **Starter** | Simple (components, lib) |
| **Dynamic** | 3-4 layer separation |
| **Enterprise** | Strict layer separation + DI container |

## Reusability Principles

### Creating Generic Functions

```typescript
// ❌ Specific
function formatUserName(user: User) {
  return `${user.firstName} ${user.lastName}`;
}

// ✅ Generic
function formatFullName(firstName: string, lastName: string) {
  return `${firstName} ${lastName}`;
}
```

### Composable Components

```tsx
// ❌ Hardcoded structure
function UserCard({ user }) {
  return <div><img src={user.avatar} /><h3>{user.name}</h3></div>;
}

// ✅ Composable
function Card({ children }) { return <div className="card">{children}</div>; }
function Avatar({ src }) { return <img src={src} className="avatar" />; }
```

### Extraction Criteria

**Extract as Function when:**
- Same logic used 2+ times
- Logic needs testing
- Can be used in other files

**Extract as Component when:**
- Same UI pattern repeats
- Has independent state
- JSX over 50 lines

## Extensibility Principles

### Configuration-Based Design

```typescript
// ❌ Listing conditionals
function getStatusColor(status: string) {
  if (status === 'active') return 'green';
  if (status === 'pending') return 'yellow';
  return 'gray';
}

// ✅ Configuration object
const STATUS_CONFIG = {
  active: { color: 'green', label: 'Active' },
  pending: { color: 'yellow', label: 'Pending' },
} as const;

function getStatusConfig(status: keyof typeof STATUS_CONFIG) {
  return STATUS_CONFIG[status] ?? { color: 'gray', label: status };
}
```

## Duplication Prevention Checklist

### Before Writing Code
- [ ] Is there a similar function in utils/?
- [ ] Is there a similar component in components/?
- [ ] Is there a similar hook in hooks/?

### After Writing Code
- [ ] Is the same code in 2+ places? → Extract
- [ ] Are there hardcoded values? → Make constants
- [ ] Is it tied to a specific type? → Generalize

## Phase Connection

| Definition (Phase 2) | Verification (Phase 8) |
|----------------------|------------------------|
| Naming rules | Naming consistency check |
| Folder structure | Structure consistency check |
| Environment variable convention | Env var naming check |
| Clean architecture principles | Dependency direction check |

## Template

See `${CLAUDE_PLUGIN_ROOT}/templates/pipeline/phase-2-convention.template.md`

## Next Phase

Phase 3: Mockup Development → Rules are set, now rapid prototyping
