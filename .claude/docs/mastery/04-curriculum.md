# 4. Learning Curriculum

> This document is part of [CLAUDE-CODE-MASTERY.md](../CLAUDE-CODE-MASTERY.md).

---

## 4.0 Level Determination Criteria

### Criteria Table

| Level | Condition | Learning Content |
|-------|-----------|------------------|
| 1 | No CLAUDE.md | Basics: CLAUDE.md writing, Plan Mode |
| 2 | Only CLAUDE.md exists | Automation: Commands, Hooks, Permission management |
| 3 | Commands/Hooks exist | Specialization: Agents, Skills, MCP |
| 4 | Most settings complete | Team optimization: GitHub Action, Team rules |

### Exclude Default Provided Files (Important!)

The following files/folders are **default learning system files** and should be **excluded** from level determination:

```bash
# Files/folders to exclude (don't count as user settings)
- .claude/commands/learn-claude-code.md      # Learning command
- .claude/commands/setup-claude-code.md      # Setup generation command
- .claude/commands/upgrade-claude-code.md    # Upgrade command
- .claude/docs/                              # Entire master guide docs
```

**Examples**:
- If `.claude/commands/` only contains the above 3 files → Judge as "No Commands"
- If `.claude/commands/commit.md` is additionally present → Judge as "Commands exist"

---

## 4.1 Level 1: Basics (15 min)

**Target**: First-time Claude Code users

**Learning Content**:
1. Purpose and writing method of CLAUDE.md
2. Basic command usage
3. Plan Mode utilization

**Practice**:
```bash
# Create CLAUDE.md
# Try adding your first rule
```

---

## 4.2 Level 2: Automation (30 min)

**Target**: Users who completed basics

**Learning Content**:
1. Create slash commands
2. Set up PostToolUse hooks
3. Permission management

**Practice**:
```bash
# Create /commit-push-pr command
# Set up formatting hook
```

---

## 4.3 Level 3: Specialization (45 min)

**Target**: Users who completed automation

**Learning Content**:
1. Create subagents
2. Define Skills
3. MCP integration

**Practice**:
```bash
# Create build-validator agent
# Create domain-specific skill
```

---

## 4.4 Level 4: Team Optimization (1 hour)

**Target**: Team leaders/architects

**Learning Content**:
1. PR automation with GitHub Action
2. Team rule standardization
3. Knowledge accumulation process

**Practice**:
```bash
# Set up claude-docs-update.yml
# Establish team CLAUDE.md rules
```
