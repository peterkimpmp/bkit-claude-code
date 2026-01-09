# Level Auto-Detection Rules

> Claude Code automatically detects project level and selects appropriate behavior.

---

## Detection Order

### Step 1: Check CLAUDE.md

Check "Level" section in project root's CLAUDE.md:

```markdown
## Project Info
- **Level**: Starter | Dynamic | Enterprise
```

If this value exists, determine that level.

### Step 2: File Structure Based Detection

If level is not specified in CLAUDE.md:

#### 🔴 Enterprise (Advanced) Conditions

**2 or more** of the following exist:

```
[ ] infra/terraform/ folder
[ ] infra/k8s/ or kubernetes/ folder
[ ] services/ folder (2+ services)
[ ] turbo.json or pnpm-workspace.yaml
[ ] docker-compose.yml
[ ] .github/workflows/ (CI/CD)
```

#### 🟡 Dynamic (Intermediate) Conditions

**1 or more** of the following exist:

```
[ ] bkend settings in .mcp.json
[ ] lib/bkend/ or src/lib/bkend/
[ ] BKEND_API_KEY environment variable reference
[ ] supabase/ folder
[ ] firebase.json
```

#### 🟢 Starter (Beginner)

None of the above conditions met

---

## Level-specific Behavior Rules

### 🟢 Starter (Beginner)

| Item | Rule |
|------|------|
| **Explanation style** | Friendly and easy terms, avoid jargon |
| **Code comments** | Detailed, understandable for beginners |
| **Error handling** | Step-by-step detailed guidance |
| **PDCA level** | Simple planning/analysis documents |
| **Reference Skills** | `skills/starter/SKILL.md` |
| **Recommended Agent** | `starter-guide` |

### 🟡 Dynamic (Intermediate)

| Item | Rule |
|------|------|
| **Explanation style** | Technical but clear |
| **Code comments** | Core logic only |
| **Error handling** | Technical causes and solutions |
| **PDCA level** | Feature-specific design documents |
| **Reference Skills** | `skills/dynamic/SKILL.md` |
| **Recommended Agent** | `bkend-expert` |

### 🔴 Enterprise (Advanced)

| Item | Rule |
|------|------|
| **Explanation style** | Use technical terms, be concise |
| **Code comments** | Architecture decisions only |
| **Error handling** | Brief cause, immediate solution |
| **PDCA level** | Detailed architecture documents |
| **Reference Skills** | `skills/enterprise/SKILL.md` |
| **Recommended Agent** | `infra-architect` |

---

## Level Upgrade Detection

### Upgrade Need Signals

```
Starter → Dynamic:
- "Add login feature"
- "Need to save data"
- "Need an admin page"

Dynamic → Enterprise:
- "Expecting high traffic"
- "Want to split into microservices"
- "Need our own server"
```

### Upgrade Suggestion Method

```
When user requests features beyond current level:

1. "This feature is more suitable for [next level]."
2. "Implementing at current level has [constraints]."
3. "Would you like to upgrade the level? `/upgrade-level [target]`"
```

---

## Hierarchical CLAUDE.md Rules

Regardless of level, reference area-specific CLAUDE.md if present:

```
project/
├── CLAUDE.md                 # Project-wide rules (always reference)
├── services/CLAUDE.md        # Additional reference for backend work
├── frontend/CLAUDE.md        # Additional reference for frontend work
└── infra/CLAUDE.md           # Additional reference for infra work
```

### Rule Conflict Resolution

```
Area-specific rules > Project-wide rules
(More specific rules take precedence)
```
