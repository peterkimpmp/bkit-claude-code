# 1. Detailed Guide for Each Setting Element

> This document is part of [CLAUDE-CODE-MASTERY.md](../CLAUDE-CODE-MASTERY.md).

---

## 1.1 CLAUDE.md (Required)

**Purpose**: Define project core rules and workflows

**Location**: Project root `/CLAUDE.md`

**Universal Template**:

```markdown
# Development Workflow

## Package Management
[Package manager and commands used in the project]

## Development Order
[Build → Test → Lint → Deploy order]

## Coding Conventions
[Language-specific style guides, forbidden patterns]
- Detailed rules document: {detected_conventions_path} (omit if none)

## Project Structure
[Folder structure and role descriptions]

## Architecture Patterns
[Architecture patterns the project follows]
- Hexagonal, Clean, MVC, MVVM, etc.

## Forbidden Practices
[Things that must never be done]

## Test Rules
[Test writing methods, locations, naming conventions]

## Document References
[Actual paths after analyzing project docs/ folder]
- Domain spec: {detected_domains_path}
- API docs: {detected_api_path}
- Dev guide: {detected_dev_path}
- Omit this section if docs/ folder doesn't exist

## Output Style Rules

Automatically adjust response style based on question type.

### Code Writing Requests
- Present code first, keep explanations concise (1-2 sentences)

### "Why?" / Concept Questions
- Explain concepts first, step by step in detail, include example code

### Error/Bug Resolution
- Root cause analysis → Solution → Prevention methods

### Code Review Requests
- List only issues (omit positives), provide corrected code
- Severity: ❌ Critical / ⚠️ Warning / 💡 Suggestion

### Refactoring Requests
- Before/After comparison, brief reasoning for changes

### Simple Questions (Yes/No)
- Answer only the core, skip unnecessary introductions

## Claude Code Configuration Guide
[Reference for Claude Code learning and configuration generation]
- **Master Guide**: `.claude/docs/CLAUDE-CODE-MASTERY.md`

### Slash Commands
- `/learn-claude-code` - Learn Claude Code usage
- `/setup-claude-code` - Auto-generate project configuration
- `/upgrade-claude-code` - Upgrade to latest trends
```

**Writing Principles**:
- Add rules every time you make mistakes (gradual improvement)
- Include specific commands/code examples
- Clearly distinguish `✅ Do` / `❌ Don't`

---

## 1.2 Commands (Recommended)

**Purpose**: Automate repetitive tasks

**Location**: `.claude/commands/{command-name}.md`

**Universal Template**:

```markdown
# {Command Name}

{One-line description}

## Usage

/{command-name} [arguments]

## Tasks Performed

### Step 1: {Task Name}
{Detailed description or command}

### Step 2: {Task Name}
{Detailed description}

## Result Output

```
✅ {Completion message}
**{Item}**: {Value}
```
```

**Universal Recommended Commands**:

| Command | Purpose | All Projects |
|---------|---------|:------------:|
| `/commit-push-pr` | Commit → Push → Create PR | ✅ |
| `/typecheck` | Type checking | Typed languages only |
| `/test` | Run tests | ✅ |
| `/lint-fix` | Auto-fix lint | ✅ |
| `/build` | Build | ✅ |
| `/format` | Code formatting | ✅ |

---

## 1.3 Agents (Subagents) (Recommended)

**Purpose**: Specialize in specific tasks

**Location**: `.claude/agents/{agent-name}.md`

### YAML Frontmatter Options (Official Spec)

| Field | Required | Type | Default | Description |
|-------|:--------:|------|---------|-------------|
| `name` | ✓ | String | — | Unique identifier (lowercase, hyphens) |
| `description` | ✓ | String | — | Role description (used for matching in auto-delegation) |
| `tools` | | CSV | Inherit all | Allowed tools (comma-separated) |
| `model` | | String | `sonnet` | Model: `sonnet`, `opus`, `haiku`, `inherit` |
| `permissionMode` | | String | `default` | Permission handling mode |
| `skills` | | CSV | None | Skills to auto-load (comma-separated) |

### Agent Locations and Priority

| Type | Location | Scope | Priority |
|------|----------|-------|:--------:|
| Project | `.claude/agents/` | Current project | Highest |
| CLI-defined | `--agents` flag | Session | High |
| Plugin | `agents/` inside plugin | Plugin | Medium |
| User | `~/.claude/agents/` | All projects | Low |

### Permission Mode Options (Complete)

| Mode | Description |
|------|-------------|
| `default` | Default permission request |
| `acceptEdits` | Auto-approve edits |
| `dontAsk` | Execute without permission questions |
| `bypassPermissions` | Completely bypass permissions (caution) |
| `plan` | Plan mode only |
| `ignore` | Ignore permission requests |

### Agent Invocation Methods

**1. Auto-delegation** (description-based)

```yaml
# Include "PROACTIVELY" or "MUST BE USED" in description for recommended auto-invocation
description: Expert code reviewer. Use PROACTIVELY after code changes.
```

**2. Explicit Invocation**

```
> Use the test-runner subagent to fix failing tests
> Have the code-reviewer subagent look at my recent changes
> Ask the debugger subagent to investigate this error
```

**3. CLI-based Definition**

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer...",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

**4. Resume Agent**

```
> Resume agent abc123 and now analyze the authorization logic as well
```

Agents have unique `agentId`, conversations are saved in `agent-{agentId}.jsonl`

### Built-in Subagents

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| **General-purpose** | Sonnet | All | Complex multi-step tasks |
| **Plan** | Sonnet | Read, Glob, Grep, Bash | Codebase exploration, research |
| **Explore** | Haiku | Glob, Grep, Read, Bash (read-only) | Fast codebase search |

**Explore Thoroughness Levels**: `Quick`, `Medium`, `Very thorough`

### Universal Template

```yaml
---
name: {agent-name}
description: {Role description}. Use PROACTIVELY when {trigger situation}.
tools: Read, Grep, Glob, Bash
model: sonnet
skills: {related-skill}
---

# {Agent Name}

{Detailed system prompt}

## Tasks Performed
1. {Task 1}
2. {Task 2}

## Success Criteria
- {Criterion 1}
- {Criterion 2}
```

### Universal Recommended Agents

| Agent | Role | All Projects |
|-------|------|:------------:|
| `build-validator` | Build validation | ✅ |
| `code-reviewer` | Code review | ✅ |
| `test-runner` | Test execution analysis | ✅ |
| `security-scanner` | Security vulnerability check | ✅ |
| `debugger` | Error analysis/root cause | ✅ |
| `api-doc-generator` | API documentation generation | Backend |
| `verify-app` | E2E testing | Frontend |

### Agent Management Commands

```bash
/agents  # Open interactive menu
         # - List agents
         # - Create new agent
         # - Edit/delete existing agents
         # - Manage tool permissions
```

### Key Constraints

- **Context Separation**: Each subagent runs in a separate context
- **No Nesting**: Subagents cannot create other subagents
- **No Skill Inheritance**: Parent conversation skills not auto-inherited (explicit `skills` required)
- **Conflict Resolution**: Project level takes precedence over user level

---

## 1.4 Skills (Optional, Recommended for Large Projects)

**Purpose**: Provide domain-specific expert context

**Location**: `.claude/skills/{skill-name}/SKILL.md`

### YAML Frontmatter Options (Official Spec)

| Field | Required | Description | Constraints |
|-------|:--------:|-------------|-------------|
| `name` | ✓ | Skill name | Lowercase, numbers, hyphens only (max 64 chars), should match folder name |
| `description` | ✓ | Skill purpose and activation timing | **Max 1024 chars**, used by Claude for semantic matching |
| `allowed-tools` | | Tools allowed when activated | Comma-separated (e.g., `Read, Grep, Glob`) |
| `model` | | Model to use when skill is activated | e.g., `claude-sonnet-4-20250514` |

### Skill Matching and Activation Process

```
1. Discovery (at start)
   └── Load only name, description of each skill

2. Activation (request matching)
   └── Compare semantic similarity between user request and description
   └── Request "skill usage" on match

3. Execution (activation)
   └── Load full SKILL.md into context
   └── Load reference files as needed
```

**Important**: Trigger keywords must be included in `description`!

```yaml
# ✅ Good example: Include specific keywords
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files, forms, or document extraction.

# ❌ Bad example: Too vague
description: Helps with documents
```

### Skill Locations and Priority

| Location | Path | Scope | Priority |
|----------|------|-------|:--------:|
| Enterprise | managed settings | Entire organization | 1 (Highest) |
| Personal | `~/.claude/skills/` | Personal, all projects | 2 |
| Project | `.claude/skills/` | Team, repository | 3 |
| Plugin | Inside plugin | Plugin users | 4 (Lowest) |

**Priority Rule**: Same-named skills favor higher priority

### Progressive Disclosure Pattern

Keep `SKILL.md` **under 500 lines**:

```
my-skill/
├── SKILL.md           # Required - Overview and navigation
├── reference.md       # Detailed docs (load when needed)
├── examples.md        # Usage examples
└── scripts/
    └── validate.py    # Utility scripts
```

**Core Principles**:
- Reference supporting files with markdown links
- References only 1 level deep (A→B ✓, A→B→C ✗)
- Instruct to **execute** scripts (not read)

```markdown
# Instructing script execution in SKILL.md
For form validation, run the following script:
```bash
python scripts/validate_form.py input.pdf
```
```

### Using Skills in Subagents

Subagents **do not auto-inherit skills**. Grant explicitly with `skills` field:

```yaml
# .claude/agents/code-reviewer.md
---
name: code-reviewer
description: Code quality and security review
skills: pr-review, security-check
---
```

**Note**: Built-in agents (Explore, Plan, Verify) and Task tool cannot access skills

### Universal Template

```yaml
---
name: {project}-{domain}
description: {Specific feature description}. Use when {list trigger keywords}.
allowed-tools: Read, Grep, Glob
---

# {Title}

## Quick Start
[Quick start example]

## Core Rules
[Rules that must be followed]

Detailed docs: [REFERENCE.md](REFERENCE.md)
Usage examples: [EXAMPLES.md](EXAMPLES.md)
```

### Skill Creation Strategy: Hybrid Approach

**Step 1: Common Skills** (all projects)

| Skill | Purpose |
|-------|---------|
| `{project}-architecture` | Overall architecture, folder structure, dependency direction |
| `{project}-testing` | Test patterns, unit/integration tests, execution methods |

**Step 2: Project Type-specific Skills** (suggested after structure analysis)

| Project Type | Detection Criteria | Suggested Skills |
|--------------|-------------------|------------------|
| **Hexagonal/DDD** | `modules/`, `domains/` | `{project}-{domain}`, `{project}-database`, `{project}-validation` |
| **Monorepo** | `packages/`, `apps/` | `{project}-{package}`, `{project}-shared` |
| **Frontend** | `components/`, `pages/` | `{project}-components`, `{project}-routing`, `{project}-state` |
| **MVC Backend** | `controllers/`, `routes/` | `{project}-controllers`, `{project}-models`, `{project}-middleware` |
| **Microservices** | `services/` | `{project}-{service}`, `{project}-messaging`, `{project}-deployment` |
| **Library** | `src/` only | `{project}-api`, `{project}-examples` |

**Step 3: Tech Stack-specific Skills** (dependency analysis)

| Detection Criteria | Suggested Skills |
|-------------------|------------------|
| MongoDB (mongoose) | `{project}-database` |
| Fastify/Express | `{project}-api-conventions` |
| Zod | `{project}-validation` |
| Redis | `{project}-cache` |
| GraphQL | `{project}-graphql` |
| Docker | `{project}-deployment` |

**Universal Utility Skills**:

| Skill | Purpose |
|-------|---------|
| `explaining-code` | Code explanation (diagram generation) |
| `commit-messages` | Commit message generation |
| `pdf-processing` | PDF file processing |

---

## 1.5 Hooks (settings.local.json) (Recommended)

**Purpose**: Automate before/after tool execution, permission management

**Location**: `.claude/settings.local.json`

### All Hook Events (Official Spec)

| Hook Event | Execution Timing | Matcher | Primary Purpose |
|------------|------------------|:-------:|-----------------|
| **PreToolUse** | Before tool execution | ✅ | Approve/reject, input validation/modification |
| **PermissionRequest** | When permission dialog shown | ✅ | Auto-approve/reject, input modification |
| **PostToolUse** | After tool execution | ✅ | Formatting, linting, logging |
| **Notification** | When notification occurs | ✅ | Custom notifications |
| **UserPromptSubmit** | When prompt submitted | ❌ | Context injection, validation |
| **Stop** | When Claude response completes | ❌ | Intelligent continue/stop decision |
| **SubagentStop** | When subagent completes | ❌ | Task completion verification |
| **PreCompact** | Before conversation compaction | ✅ | Pre-compaction settings |
| **SessionStart** | When session starts | ✅ | Environment variables, context loading |
| **SessionEnd** | When session ends | ❌ | Cleanup, logging |

**Notification matcher**: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`
**SessionStart matcher**: `startup`, `resume`, `clear`, `compact`
**PreCompact matcher**: `manual`, `auto`

### Hook Configuration Structure

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "ToolPattern",
        "hooks": [
          {
            "type": "command",
            "command": "bash-command",
            "timeout": 60
          }
        ]
      }
    ]
  }
}
```

### Matcher Patterns

| Pattern | Description | Example |
|---------|-------------|---------|
| Exact match | Specific tool only | `Write` |
| Regex | OR pattern | `Edit\|Write` |
| Wildcard | Match all | `*` or `""` |
| MCP tool | MCP server tools | `mcp__memory__.*` |

### Hook Types

**1. Command Hook** (`type: "command"`)

```json
{
  "type": "command",
  "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/validate.sh",
  "timeout": 60
}
```

**2. Prompt Hook** (`type: "prompt"`)

Used in `Stop`, `SubagentStop`, `UserPromptSubmit`, `PreToolUse`, `PermissionRequest`:

```json
{
  "type": "prompt",
  "prompt": "Evaluate if Claude should stop: $ARGUMENTS\n\nRespond with JSON: {\"decision\": \"approve\" or \"block\", \"reason\": \"explanation\"}",
  "timeout": 30
}
```

### Environment Variables

| Variable | Description |
|----------|-------------|
| `$CLAUDE_PROJECT_DIR` | Project root absolute path |
| `$CLAUDE_CODE_REMOTE` | `"true"` for web, empty for CLI |
| `$CLAUDE_ENV_FILE` | Environment variable storage file path (SessionStart) |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin directory |

### Hook Input (JSON via stdin)

**Common Fields**:

```json
{
  "session_id": "string",
  "transcript_path": "string",
  "cwd": "string",
  "permission_mode": "default|plan|acceptEdits|dontAsk|bypassPermissions",
  "hook_event_name": "string"
}
```

**Event-specific Additional Fields**:

| Event | Additional Fields |
|-------|-------------------|
| PreToolUse | `tool_name`, `tool_input`, `tool_use_id` |
| PostToolUse | `tool_name`, `tool_input`, `tool_response`, `tool_use_id` |
| UserPromptSubmit | `prompt` |
| Stop/SubagentStop | `stop_hook_active` |
| SessionStart | `source` (startup/resume/clear/compact) |
| SessionEnd | `reason` (clear/logout/prompt_input_exit/other) |
| Notification | `message`, `notification_type` |
| PreCompact | `trigger` (manual/auto), `custom_instructions` |

### Hook Output

**Exit Code**:

| Code | Behavior | Usage |
|:----:|----------|-------|
| 0 | Success - process stdout/JSON | Normal operation |
| 2 | Block - display stderr | Block operation, show error |
| Other | Non-blocking warning | Display in verbose mode |

**JSON Output** (only when exit 0):

```json
{
  "continue": true,
  "stopReason": "Message when continue=false",
  "suppressOutput": false,
  "systemMessage": "Warning to show user"
}
```

### Event-specific Decision Control

**PreToolUse**:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "explanation",
    "updatedInput": { "field": "modified value" }
  }
}
```

**PermissionRequest**:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow|deny",
      "updatedInput": {},
      "message": "rejection reason",
      "interrupt": false
    }
  }
}
```

**Stop/SubagentStop**:

⚠️ **Caution**: Do NOT request JSON format for Prompt type hooks! Internal schema differs from documentation.

```json
// Actual schema expected by internal system (undocumented)
{
  "ok": true,        // boolean - whether task is complete
  "reason": "..."    // required when ok=false
}
```

**Correct Usage**: Evaluate in natural language and internal system will convert
```json
{
  "type": "prompt",
  "model": "sonnet",
  "prompt": "Evaluate if Claude should stop. If complete, stop. If not, explain what remains."
}
```

### Practical Hook Examples

**1. File Write Formatting**:

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "npx prettier --write \"$(cat | jq -r '.tool_input.file_path')\" 2>/dev/null || true"
      }]
    }]
  }
}
```

**2. .env File Protection**:

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "python3 -c \"import json,sys; d=json.load(sys.stdin); p=d.get('tool_input',{}).get('file_path',''); sys.exit(2 if '.env' in p or 'secret' in p.lower() else 0)\""
      }]
    }]
  }
}
```

**3. Session Start Environment Setup**:

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "startup",
      "hooks": [{
        "type": "command",
        "command": "if [ -n \"$CLAUDE_ENV_FILE\" ]; then echo 'export NODE_ENV=development' >> \"$CLAUDE_ENV_FILE\"; fi"
      }]
    }]
  }
}
```

**4. Intelligent Stop Hook** (Prompt type):

⚠️ Do NOT request JSON format! Must evaluate in natural language.

```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "prompt",
        "model": "sonnet",
        "prompt": "Evaluate if Claude should stop. Check: 1) All user requests complete 2) No errors to fix 3) No follow-up needed. If complete, Claude can stop. If not, explain what remains."
      }]
    }]
  }
}
```

### Permission Settings

```json
{
  "permissions": {
    "allow": [
      "Bash({PACKAGE_MANAGER}:*)",
      "Bash({BUILD_COMMAND}:*)",
      "Bash({TEST_COMMAND}:*)"
    ],
    "deny": [],
    "ask": []
  }
}
```

---

## 1.6 MCP (Model Context Protocol) (Optional)

**Purpose**: External tool integration (Slack, GitHub, Jira, etc.)

### File Locations and Scopes

| Scope | Location | Purpose |
|-------|----------|---------|
| **Project** | `.mcp.json` (project root) | Team sharing, include in version control |
| **Local** | `~/.claude.json` (project subdirectory) | Personal development, sensitive credentials |
| **User** | `~/.claude.json` (global) | Access from all projects |
| **Enterprise** | `/Library/Application Support/ClaudeCode/managed-mcp.json` | Entire organization |

**Scope Priority**: Local > Project > User

### Server Types

**1. HTTP Server** (Recommended)

```bash
claude mcp add --transport http stripe https://mcp.stripe.com

# With Bearer token
claude mcp add --transport http api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

**2. SSE Server** (Server-Sent Events)

```bash
claude mcp add --transport sse asana https://mcp.asana.com/sse \
  --header "X-API-Key: your-key"
```

**3. Stdio Server** (Local)

```bash
claude mcp add --transport stdio airtable \
  --env AIRTABLE_API_KEY=YOUR_KEY \
  -- npx -y airtable-mcp-server

# Windows: cmd /c wrapper required
claude mcp add --transport stdio my-server -- cmd /c npx -y @some/package
```

**`--` Parameter**: Before `--` are CLI options, after are MCP server commands

### .mcp.json Structure

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    },
    "database": {
      "type": "stdio",
      "command": "/usr/local/bin/db-server",
      "args": ["--config", "/etc/config.json"],
      "env": {
        "DB_URL": "${DB_URL}",
        "CACHE_DIR": "/tmp"
      }
    },
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

### Environment Variable Syntax

| Syntax | Description |
|--------|-------------|
| `${VAR}` | Direct environment variable reference |
| `${VAR:-default}` | Default value when unset |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin root path |

### Key CLI Commands

```bash
# Add server
claude mcp add --transport <type> <name> <url/command>
claude mcp add --transport http github --scope project https://mcp.github.com

# Add as JSON
claude mcp add-json <name> '<json>'

# Import from Claude Desktop
claude mcp add-from-claude-desktop

# List/details/remove
claude mcp list
claude mcp get <name>
claude mcp remove <name>

# OAuth authentication (inside Claude Code)
/mcp

# Reset project approval choices
claude mcp reset-project-choices
```

### Using MCP Resources and Prompts

```bash
# Reference resources with @ mention
> Can you analyze @github:issue://123 and suggest a fix?
> Compare @postgres:schema://users with @docs:file://api/auth

# MCP prompts as slash commands
/mcp__github__list_prs
/mcp__github__pr_review 456
```

### Output Limits

- **Warning threshold**: Warning when exceeding 10,000 tokens
- **Default limit**: 25,000 tokens
- **Adjust**: `MAX_MCP_OUTPUT_TOKENS=50000 claude`

### Default MCP Servers (Recommended for All Projects)

| Server | Purpose | Install Command |
|--------|---------|-----------------|
| **Slack** | Team communication, notifications | `claude mcp add slack` |
| **GitHub** | PR/issue management, code review | `claude mcp add github` |

### Useful MCP Server List

**📊 Databases**

| Server | Description | Detection Criteria |
|--------|-------------|-------------------|
| PostgreSQL | Relational DB queries | `pg`, `postgres` dependency |
| MongoDB | NoSQL (Atlas support) | `mongoose`, `mongodb` dependency |
| Redis | Key-value store/cache | `redis`, `ioredis` dependency |
| Elasticsearch | Search engine | `@elastic/elasticsearch` dependency |
| DuckDB | Data analysis | `duckdb` dependency |

**🌐 Web & Browser**

| Server | Description |
|--------|-------------|
| Fetch | Fetch/convert web content |
| Puppeteer | Browser automation |
| Firecrawl | Web scraping |
| Browserbase | Cloud browser |

**💼 Collaboration & Productivity**

| Server | Description |
|--------|-------------|
| Notion | Document/database management |
| Linear | Issue tracking |
| Atlassian | Jira/Confluence |
| Asana | Project management |

**💰 Payments & Finance**

| Server | Description | Detection Criteria |
|--------|-------------|-------------------|
| Stripe | Payment processing | `stripe` dependency |
| PayPal | Payment processing | `@paypal/checkout-server-sdk` |

**🔐 Security & Monitoring**

| Server | Description | Detection Criteria |
|--------|-------------|-------------------|
| Sentry | Error monitoring | `@sentry/*` dependency |
| Datadog | APM/logging | `dd-trace` dependency |

**☁️ Cloud & Infrastructure**

| Server | Description | Detection Criteria |
|--------|-------------|-------------------|
| AWS | AWS services | `@aws-sdk/*` dependency |
| Firebase | Backend services | `firebase-admin` dependency |

**🛠️ Development Tools**

| Server | Description |
|--------|-------------|
| Git | Repository operations |
| Filesystem | File operations |
| Memory | Knowledge graph memory |
| E2B | Code sandbox |

### Project-based MCP Recommendation Strategy

When running `/setup-claude-code`, analyze project dependencies to recommend MCP servers:

```
1. Default servers (auto-add)
   └── Slack, GitHub

2. Dependency analysis (package.json, requirements.txt, etc.)
   ├── mongoose/mongodb → Recommend MongoDB MCP
   ├── pg/postgres → Recommend PostgreSQL MCP
   ├── redis/ioredis → Recommend Redis MCP
   ├── stripe → Recommend Stripe MCP
   ├── @sentry/* → Recommend Sentry MCP
   ├── @aws-sdk/* → Recommend AWS MCP
   └── firebase-admin → Recommend Firebase MCP

3. User confirmation (AskUserQuestion)
   └── Provide recommended server selection UI
```

**Recommendation Prompt Example**:

```markdown
Based on project analysis, we recommend the following MCP servers:

✅ Default (auto-add):
- Slack (team communication)
- GitHub (PR/issue management)

📦 Dependencies detected:
- [x] MongoDB (mongoose detected)
- [x] Redis (ioredis detected)
- [ ] Stripe (can be deselected)

🔧 Additional options:
- [ ] Notion (document management)
- [ ] Sentry (error monitoring)

Add selected servers to .mcp.json?
```

**References**:
- Full MCP server list: https://github.com/modelcontextprotocol/servers
- MCP Registry: https://registry.modelcontextprotocol.io/

---

## 1.7 GitHub Action (Optional)

**Purpose**: Auto-update documentation via PR comments

**Location**: `.github/workflows/claude-docs-update.yml`

**Universal Template**:

```yaml
name: Claude Documentation Update

on:
  pull_request_review_comment:
    types: [created]
  issue_comment:
    types: [created]

jobs:
  update-docs:
    if: |
      contains(github.event.comment.body, '@claude') &&
      (github.event_name == 'pull_request_review_comment' ||
       (github.event_name == 'issue_comment' && github.event.issue.pull_request))
    runs-on: ubuntu-latest

    permissions:
      contents: write
      pull-requests: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Run Claude Code
        uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
          comment: ${{ github.event.comment.body }}

      - name: Commit changes
        run: |
          git config --local user.email "claude-bot@anthropic.com"
          git config --local user.name "Claude Bot"
          git add -A
          if git diff --staged --quiet; then
            echo "No changes to commit"
          else
            git commit -m "docs: Claude updated documentation

            Request: ${{ github.event.comment.body }}

            Co-Authored-By: Claude <claude-bot@anthropic.com>"
            git push
          fi
```
