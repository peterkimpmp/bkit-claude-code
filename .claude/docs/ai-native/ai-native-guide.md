# AI Native Development Guide

> **Purpose**: Methodology for building Enterprise-grade systems with AI collaboration.
> **Case Study**: bkamp.ai - 13 microservices, 588 commits, 5 weeks, 1 developer + Claude Code

---

## Table of Contents

1. [What is AI Native Development](#1-what-is-ai-native-development)
2. [Success Prerequisites](#2-success-prerequisites)
3. [10-Day Development Pattern](#3-10-day-development-pattern)
4. [Document-First Design](#4-document-first-design)
5. [Monorepo Context Control](#5-monorepo-context-control)
6. [AI Native QA](#6-ai-native-qa)
7. [Team Application](#7-team-application)
8. [Anti-Patterns](#8-anti-patterns)

---

## 1. What is AI Native Development

### 1.1 Definition

AI Native Development is a methodology where:
- AI (Claude Code) is a **core development partner**, not just a tool
- **Documents** serve as shared context between human and AI
- **PDCA cycle** ensures continuous improvement
- **PR-based workflow** maintains quality and history

### 1.2 Key Differences from Traditional Development

| Aspect | Traditional | AI Native |
|--------|-------------|-----------|
| **Design Phase** | For humans to read | For AI to understand |
| **Documentation** | Optional, often outdated | Required, AI context |
| **Code Generation** | Human writes everything | AI generates, human verifies |
| **QA Process** | Test scripts | Real-time log analysis |
| **Development Speed** | Linear with team size | Multiplied with AI collaboration |

### 1.3 When to Use

**Good Fit:**
- Rapid prototyping / MVP development
- Solo development with enterprise requirements
- Projects with clear architecture patterns
- Teams with strong senior developers

**Poor Fit:**
- Novel algorithm development
- Performance-critical systems requiring deep optimization
- Teams without verification capabilities
- Highly regulated environments with audit requirements

---

## 2. Success Prerequisites

> **Critical Warning**: These prerequisites determine success or failure.

### 2.1 Three Essential Capabilities

```
┌─────────────────────────────────────────────────────────────┐
│                 AI Native Prerequisites                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. VERIFICATION                                            │
│     ├─ Can judge correctness of AI output                   │
│     ├─ Spot bugs in generated code                          │
│     ├─ Identify security vulnerabilities                    │
│     └─ Assess architectural decisions                       │
│                                                             │
│  2. DIRECTION                                               │
│     ├─ Clear requirements definition                        │
│     ├─ Architecture design capability                       │
│     ├─ Technology selection expertise                       │
│     └─ Priority management                                  │
│                                                             │
│  3. QUALITY BAR                                             │
│     ├─ Define "good enough" standards                       │
│     ├─ Security requirements awareness                      │
│     ├─ Performance expectations                             │
│     └─ Maintainability criteria                             │
│                                                             │
│  WITHOUT THESE:                                             │
│  "AI becomes a tool for producing mistakes faster"          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 The "No Guessing" Paradox

The principle "Don't guess" only works if you can **detect** when AI guesses:

```
Senior Developer:
  AI guesses → "No, this is wrong" → Correct instruction → Good result

Junior Developer:
  AI guesses → "Oh, I see" → Apply as-is → Bug introduced
```

Having "Don't guess" in Skills is meaningless if you can't recognize guesses.

### 2.3 Honest Assessment Questions

Before starting AI Native development, ask:

1. **Can I review AI-generated code and find bugs?**
   - Yes → Proceed
   - No → Get senior oversight

2. **Can I define the architecture before AI implements?**
   - Yes → Proceed
   - No → Study architecture patterns first

3. **Do I know what "good code" looks like for this project?**
   - Yes → Proceed
   - No → Define quality standards first

---

## 3. 10-Day Development Pattern

### 3.1 Timeline Overview

```
Day 1:  Architecture Design ──────────────┐
                                          │
Day 2-3: Core Development ────────────────┤ MVP
                                          │
Day 4-5: UX Refinement ───────────────────┘
                                          │
Day 6-7: QA Cycle ────────────────────────┤ Stabilization
                                          │
Day 8:  Infrastructure ───────────────────┤
                                          │
Day 9-10: Production ─────────────────────┘ Launch
```

### 3.2 Day-by-Day Breakdown

#### Day 1: Architecture Design
```
Morning:
├─ Market analysis with AI
├─ Business requirements documentation
└─ System architecture design

Afternoon:
├─ Technology stack decision
├─ Database schema design
└─ API contract definition

Output:
├─ docs/00-requirement/market-analysis.md
├─ docs/01-development/01_architecture.md
└─ docs/01-development/02_database-schema.md
```

#### Day 2-3: Core Development
```
Day 2:
├─ Monorepo setup
├─ Shared modules (auth, database, errors)
├─ Core services implementation
└─ API endpoints

Day 3:
├─ Frontend scaffold
├─ E2E integration
└─ Basic UI implementation

Output:
├─ services/shared/
├─ services/auth/, user/, etc.
└─ frontend/portal/
```

#### Day 4-5: UX Refinement
```
Process:
1. Product Owner tests UI
2. Feedback documented (not verbal)
3. AI implements documented changes
4. Repeat cycle

Output:
├─ docs/02-scenario/feedback-round-{n}.md
└─ Multiple PRs with targeted fixes
```

#### Day 6-7: QA Cycle
```
Zero Script QA Process:
1. Start Docker environment
2. Claude monitors logs
3. Human tests features manually
4. Claude detects errors in real-time
5. Claude fixes immediately
6. Repeat until stable

Output:
├─ docs/03-refactoring/qa-results.md
└─ Bug fix PRs
```

#### Day 8: Infrastructure
```
Tasks:
├─ Terraform modules (VPC, EKS, RDS, S3)
├─ Kubernetes manifests (base + overlays)
├─ ArgoCD application definitions
└─ CI/CD pipeline

Output:
├─ infra/terraform/
├─ infra/k8s/
└─ .github/workflows/
```

#### Day 9-10: Production
```
Day 9:
├─ Security review
├─ Performance testing
├─ Multi-language support
└─ Final documentation

Day 10:
├─ Production deployment
├─ Monitoring setup
└─ Launch verification

Output:
├─ Production URL live
└─ Monitoring dashboards
```

---

## 4. Document-First Design

### 4.1 Why Documents Matter for AI

```
Traditional:
  Developer → Code → Sometimes Document

AI Native:
  Human + AI → Document → AI → Code → Update Document
```

Documents serve as **shared context** between human and AI.

### 4.2 Document Structure

```
docs/
├── 00-requirement/      # Business context (4 docs)
│   └── 01_market-analysis.md
├── 01-development/      # Initial design (14 docs)
│   ├── 01_architecture.md
│   └── 02_database-schema.md
├── 02-scenario/         # Implementation analysis
├── 03-refactoring/      # Improvement records (50+ docs)
└── 04-operation/        # Operation guides
```

### 4.3 Numbering Convention

| Prefix | Meaning |
|--------|---------|
| `00-` | Requirements phase |
| `01-` | Initial design phase |
| `02-` | Implementation phase |
| `03-` | Refinement phase |
| `04-` | Operation phase |

File numbers within folders indicate sequence.

### 4.4 AI-Friendly Document Format

**Good:**
```markdown
## API Endpoint: Create User

### Request
- Method: POST
- Path: /api/v1/users
- Body:
  ```json
  {"email": "string", "name": "string"}
  ```

### Response
- 201: User created
- 400: Validation error
- 409: Email exists
```

**Bad:**
```markdown
The user creation endpoint should handle various cases
and return appropriate responses based on the situation.
```

---

## 5. Monorepo Context Control

### 5.1 Why Monorepo for AI

```
Multi-repo:
├─ frontend-repo (AI reads partially)
├─ backend-repo (AI reads partially)
├─ infra-repo (AI reads partially)
└─ Context fragmented across repos

Mono-repo:
└─ bkamp-portal/
    ├─ frontend/ (AI reads)
    ├─ services/ (AI reads)
    ├─ infra/ (AI reads)
    └─ Complete context in one place
```

### 5.2 CLAUDE.md Hierarchy

```
project/
├── CLAUDE.md                 # Global rules (always read)
├── services/CLAUDE.md        # Backend conventions
│   └── {service}/            # Service-specific (if needed)
├── frontend/CLAUDE.md        # Frontend conventions
└── infra/CLAUDE.md           # Infra conventions
```

### 5.3 CLAUDE.md Template

```markdown
# {Area} Conventions

## Directory Structure
{tree showing key folders}

## Coding Standards
{specific rules for this area}

## API Response Format
{if applicable}

## Common Patterns
{reusable code patterns}

## Do's and Don'ts
✅ Do: {correct approach}
❌ Don't: {incorrect approach}
```

### 5.4 Shared Module Design

```python
services/shared/
├── auth/           # JWT token management
├── database/       # SQLAlchemy connection
├── errors/         # Unified error codes
├── schemas/        # CamelCase base models
├── logging/        # Structured logging
└── utils/          # Helper functions
```

All services import from shared → **Consistency guaranteed**.

---

## 6. AI Native QA

### 6.1 Traditional vs AI Native QA

| Aspect | Traditional | AI Native |
|--------|-------------|-----------|
| **Test Writing** | Developer writes scripts | E2E scripts + log analysis |
| **Feedback Speed** | Minutes to hours | Seconds |
| **Regression** | Test suite execution | Documented test cycles |
| **Bug Detection** | Test failure | Claude detects in logs |
| **Fix Cycle** | PR → Review → Merge → CI | Detect → Fix → Verify |

### 6.2 Zero Script QA Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                   AI Native QA Workflow                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Start Docker environment                                │
│     └─ docker compose up                                    │
│                                                             │
│  2. Claude monitors logs                                    │
│     └─ docker compose logs -f                               │
│     └─ Analyzes JSON logs in real-time                      │
│                                                             │
│  3. Human tests UI manually                                 │
│     └─ Click buttons, submit forms, navigate pages          │
│                                                             │
│  4. Claude detects issues                                   │
│     └─ ERROR level logs detected                            │
│     └─ Request ID traced across services                    │
│     └─ Stack traces analyzed                                │
│                                                             │
│  5. Immediate fix and verify                                │
│     └─ Problem code identified                              │
│     └─ Fix applied with hot reload                          │
│     └─ Same action retested                                 │
│                                                             │
│  6. Repeat until stable                                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 6.3 Iterative Test Cycles

Example from bkamp notification feature:

| Cycle | Pass Rate | Bug Found |
|-------|-----------|-----------|
| 1st | 30% | DB schema mismatch |
| 2nd | 45% | NULL handling missing |
| 3rd | 55% | Routing error |
| 4th | 65% | Type mismatch |
| 5th | 70% | Calculation logic error |
| 6th | 75% | Event missing |
| 7th | 82% | Cache sync issue |
| 8th | **89%** | Stable |

### 6.4 Log Format for AI Analysis

```json
{
  "timestamp": "2025-12-10T10:23:45.123Z",
  "level": "ERROR",
  "service": "auth-service",
  "request_id": "req_abc123",
  "message": "Token validation failed",
  "data": {
    "user_id": "user_xyz",
    "error_code": "AUTH_001"
  }
}
```

Required fields for effective AI analysis:
- `timestamp`: ISO 8601 format
- `level`: DEBUG|INFO|WARNING|ERROR
- `service`: Service identifier
- `request_id`: Request tracing ID
- `message`: Log message
- `data`: Additional context (optional)

---

## 7. Team Application

### 7.1 Role Structure

```
Senior (Architect/Tech Lead)
├─ Architecture design
├─ Skill/Command/Guidelines creation
├─ Code review and quality verification
│
└─▶ Junior/Mid-level
    ├─ Work within senior's guardrails
    ├─ Implement using defined patterns
    └─ Results reviewed by senior (required)
```

### 7.2 Guardrail System

- Skills as **mandatory** not "recommended"
- PR review **required** (AI-generated code included)
- Automated quality checks (linter, type check, security scan)
- CI/CD tests **must pass**

### 7.3 Capability Training

| Capability | Training Content |
|------------|-----------------|
| **Prompt Engineering** | Clear, specific instruction writing |
| **Result Verification** | Judging AI output accuracy |
| **Architecture Basics** | Good vs bad structure recognition |
| **Debugging** | Tracking and fixing AI-generated bugs |

---

## 8. Anti-Patterns

### 8.1 Common Mistakes

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| **Blind Trust** | Accept AI output without review | Always verify |
| **Verbal Instructions** | Not documenting feedback | Write it down |
| **Skipping PDCA** | No Check phase | Always verify before next cycle |
| **Context Fragmentation** | Multiple repos | Use monorepo |
| **Outdated Docs** | Docs don't match code | Codebase is truth |

### 8.2 Signs of Failure

Watch for these warning signs:

1. **Bugs keep recurring** → Verification capability missing
2. **"Claude said to do it this way"** → Direction capability missing
3. **"It works but looks wrong"** → Quality bar missing
4. **Constant rework** → Document-first not followed
5. **Integration failures** → Monorepo context not used

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-09 | Initial creation based on bkamp experience |
