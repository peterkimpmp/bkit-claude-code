# PDCA Hooks Guide

## Overview

Hooks are validation/guidance logic that automatically executes on specific Claude Code events.
They are designed to naturally apply PDCA methodology.

## Configuration Location

```
.claude/settings.local.json
```

## Hook Event Types (v2.1.1 Update)

| Event | Trigger Point | Purpose |
|-------|---------------|---------|
| **SessionStart** | On session start | Onboarding, context setup |
| **PreToolUse** | Before tool use | Validation, guidance, blocking |
| **PostToolUse** | After tool use | Post-processing, notifications |
| **Stop** | On response completion | Checklists, summaries |
| **SubagentStop** | On subagent completion | Result validation |
| **PreCompact** | Before context compaction | Preserve important information |
| **UserPromptSubmit** | On user input submission | Input validation, transformation |
| **Notification** | On notification occurrence | Notification handling |

---

## Currently Configured Hooks

### 1. PreToolUse - Write

**Trigger**: Before file writing

**Purpose**: Design document verification reminder

```json
{
  "matcher": "Write",
  "hooks": [{
    "type": "prompt",
    "prompt": "Before writing file: 1) Check related design documents..."
  }]
}
```

**Effect**:
- Prevents implementation without design
- Encourages following existing patterns
- Reinforces PDCA "Plan → Do" flow

### 2. PostToolUse - Git Commit

**Trigger**: After git commit

**Purpose**: PDCA status update notification

```json
{
  "matcher": "Bash(git commit:*)",
  "hooks": [{
    "type": "prompt",
    "prompt": "Commit complete. Check if PDCA status update is needed..."
  }]
}
```

**Effect**:
- Guides to Check phase after implementation completion
- Gap analysis timing reminder
- Ensures documentation updates are not forgotten

### 3. Stop

**Trigger**: On task completion

**Purpose**: PDCA checklist reminder

```json
{
  "hooks": [{
    "type": "prompt",
    "model": "sonnet",
    "prompt": "Evaluate if Claude should stop. Check: 1) All tasks completed 2) Design-implementation aligned 3) Tests written if needed. If all complete, Claude can stop. If not, explain what remains."
  }]
}
```

**⚠️ Caution** (Claude Code Internal Bug):
- Stop/SubagentStop hooks **must NOT request JSON format**
- Internal system uses `{"ok": boolean}` schema (differs from documentation)
- **Use natural language for evaluation** and internal system will convert automatically
- `model: "sonnet"` recommended (haiku is unstable)

**Effect**:
- Final check before task completion
- Encourages PDCA cycle completion
- Quality checkpoint

## Hook Types

### prompt

Injects additional prompts to Claude.
Used for "guidance" purposes, not automation.

```json
{
  "type": "prompt",
  "prompt": "Content to check..."
}
```

### command (Advanced)

Executes shell commands. (Use with caution)

```json
{
  "type": "command",
  "command": "npm run lint"
}
```

## Customization

### Hook Addition Examples

**Auto ESLint Execution**:
```json
{
  "matcher": "Write(*.ts|*.tsx)",
  "hooks": [{
    "type": "command",
    "command": "npx eslint ${file}"
  }]
}
```

**Test Reminder**:
```json
{
  "matcher": "Write(src/**/*.ts)",
  "hooks": [{
    "type": "prompt",
    "prompt": "Does this file have tests? Check the __tests__/ folder."
  }]
}
```

## Recommended Settings by Level

| Hook | Starter | Dynamic | Enterprise |
|------|---------|---------|------------|
| PreToolUse Write | Optional | ✅ | ✅ |
| PostToolUse Commit | Optional | ✅ | ✅ |
| Stop | ✅ | ✅ | ✅ |
| Lint Automation | - | Optional | ✅ |
| Test Reminder | - | Optional | ✅ |

## Disabling

To disable a specific Hook, remove that entry from settings.local.json.

To disable all Hooks:
```json
{
  "hooks": {}
}
```

## Precautions

1. **prompt type recommended**: command may have unexpected behavior
2. **Concise messages**: Too long prompts waste context
3. **Recommended, not required**: Hooks are guidance, not enforcement
4. **Team consensus**: Share Hook settings in team projects

## Related Documentation

- [Claude Code Hooks Official Documentation](https://docs.anthropic.com/claude-code/hooks)
- [settings.json Schema](https://raw.githubusercontent.com/anthropics/claude-code/main/schemas/settings.json)
