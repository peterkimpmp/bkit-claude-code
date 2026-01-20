---
name: level-detection
description: |
  Project level detection (Starter/Dynamic/Enterprise) for bkit.
  Automatically detects project complexity and applies appropriate guidance.

  Use proactively when starting a new project or when project structure is unclear.

  Triggers: level, starter, dynamic, enterprise, project type, complexity,
  레벨, 프로젝트 유형, 複雑度, 项目类型

  Do NOT use for: ongoing implementation where level is already determined.
---

# Level Detection Rules

> Claude Code automatically detects project level and selects appropriate behavior.

## Detection Priority

### Step 1: Check CLAUDE.md

Check "Level" section in project root's CLAUDE.md:

```markdown
## Project Info
- **Level**: Starter | Dynamic | Enterprise
```

If this value exists, use that level.

### Step 2: File Structure Based Detection

If level is not specified in CLAUDE.md:

#### 🔴 Enterprise (Advanced) - 2+ conditions met:

```
[ ] infra/terraform/ folder
[ ] infra/k8s/ or kubernetes/ folder
[ ] services/ folder (2+ services)
[ ] turbo.json or pnpm-workspace.yaml
[ ] docker-compose.yml
[ ] .github/workflows/ (CI/CD)
```

#### 🟡 Dynamic (Intermediate) - 1+ conditions met:

```
[ ] bkend settings in .mcp.json
[ ] lib/bkend/ or src/lib/bkend/
[ ] BKEND_API_KEY environment variable reference
[ ] supabase/ folder
[ ] firebase.json
```

#### 🟢 Starter (Beginner)

None of the above conditions met.

---

## Level-specific Behavior

| Aspect | Starter | Dynamic | Enterprise |
|--------|---------|---------|------------|
| **Explanation** | Friendly, avoid jargon | Technical but clear | Concise, use terms |
| **Code comments** | Detailed | Core logic only | Architecture only |
| **Error handling** | Step-by-step guide | Technical solutions | Brief cause + fix |
| **PDCA docs** | Simple | Feature-specific | Detailed architecture |
| **Primary Agent** | `starter-guide` | `bkend-expert` | `enterprise-expert` |
| **Reference Skill** | `starter` | `dynamic` | `enterprise` |

---

## Level Upgrade Signals

### Starter → Dynamic

Triggers: "Add login feature", "Need to save data", "Need an admin page"

### Dynamic → Enterprise

Triggers: "Expecting high traffic", "Want to split into microservices", "Need our own server"

### Upgrade Suggestion Pattern

```
When user requests features beyond current level:

1. "This feature is more suitable for [next level]."
2. "Implementing at current level has [constraints]."
3. "Would you like to upgrade? Run `/upgrade-level [target]`"
```

---

## Hierarchical CLAUDE.md Rules

Reference area-specific CLAUDE.md if present:

```
project/
├── CLAUDE.md                 # Project-wide (always reference)
├── services/CLAUDE.md        # Backend work context
├── frontend/CLAUDE.md        # Frontend work context
└── infra/CLAUDE.md           # Infrastructure context
```

### Rule Conflict Resolution

```
Area-specific rules > Project-wide rules
(More specific rules take precedence)
```
