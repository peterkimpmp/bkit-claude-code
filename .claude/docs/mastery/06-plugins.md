# 6. Plugins

> This document is part of [CLAUDE-CODE-MASTERY.md](../CLAUDE-CODE-MASTERY.md).

---

## 6.1 What are Plugins?

**Plugins** are reusable packages that extend Claude Code's functionality. They bundle Commands, Agents, and Skills together for distribution to other projects or teams.

**Plugin vs Local Settings**:

| Aspect | Local Settings | Plugin |
|--------|----------------|--------|
| Location | `.claude/` folder | Marketplace or URL |
| Scope | Current project | Shared across projects |
| Distribution | Git | Marketplace/HTTP |
| Updates | Manual | Automatic |

---

## 6.2 Plugin Structure

```
my-plugin/
├── plugin.json              # Plugin manifest (required)
├── README.md                # Documentation
├── commands/                # Slash commands
│   └── my-command.md
├── agents/                  # Subagents
│   └── my-agent.md
├── skills/                  # Skills
│   └── my-skill/
│       └── SKILL.md
└── hooks/                   # Hook scripts
    └── format.sh
```

---

## 6.3 plugin.json (Manifest)

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Plugin description",
  "author": "Author",
  "homepage": "https://github.com/...",
  "license": "MIT",
  "claude": {
    "minVersion": "1.0.0"
  },
  "commands": ["commands/my-command.md"],
  "agents": ["agents/my-agent.md"],
  "skills": ["skills/my-skill"],
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "script": "hooks/format.sh"
    }]
  },
  "permissions": {
    "allow": ["Bash(npm:*)"],
    "deny": []
  }
}
```

**Required Fields**:

| Field | Description |
|-------|-------------|
| `name` | Unique plugin name (kebab-case) |
| `version` | Semantic Versioning (1.0.0) |
| `description` | Brief description (max 200 chars) |

**Optional Fields**:

| Field | Description |
|-------|-------------|
| `author` | Author/organization |
| `homepage` | GitHub/website URL |
| `license` | License (MIT, Apache-2.0, etc.) |
| `claude.minVersion` | Minimum Claude Code version |
| `commands` | List of commands to include |
| `agents` | List of agents to include |
| `skills` | List of skill folders to include |
| `hooks` | Hook definitions |
| `permissions` | Permission settings |

---

## 6.4 Plugin Installation

```bash
# Install from Marketplace
claude plugin install @org/plugin-name

# Install from URL
claude plugin install https://github.com/org/plugin/releases/latest/download/plugin.zip

# Install from local path
claude plugin install ./path/to/plugin
```

**Managing Installed Plugins**:

```bash
# List installed
claude plugin list

# Update
claude plugin update @org/plugin-name

# Remove
claude plugin remove @org/plugin-name
```

---

## 6.5 Plugin Development

**Step 1: Initialize Plugin**

```bash
mkdir my-plugin && cd my-plugin
claude plugin init
```

**Step 2: Add Features**

```bash
# Add command
mkdir commands
cat > commands/my-command.md << 'EOF'
# My Command

This command...

## Tasks
1. ...
2. ...
EOF
```

**Step 3: Local Testing**

```bash
# Test in current project
claude plugin link .

# Test
/my-command

# Unlink
claude plugin unlink my-plugin
```

**Step 4: Deploy**

```bash
# Package
claude plugin pack

# Publish to Marketplace
claude plugin publish

# Or deploy via GitHub Release
```

---

## 6.6 Prebuilt Plugins (Marketplace)

**Official Plugin Examples**:

| Plugin | Description |
|--------|-------------|
| `@anthropic/git-workflow` | Git workflow automation |
| `@anthropic/code-review` | Code review agent |
| `@anthropic/testing` | Test writing/running tools |
| `@anthropic/docs` | Documentation generation tools |

**Search and Install**:

```bash
# Search Marketplace
claude plugin search "testing"

# Browse popular plugins
claude plugin browse --sort=downloads

# Install
claude plugin install @anthropic/testing
```
