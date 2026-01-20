# Hooks Simplification Design

> **Created**: 2026-01-19
> **Status**: Implemented
> **Purpose**: Remove unstable Hooks system and replace with Skills

---

## 1. Background

### 1.1 Problem Statement

- Claude Code Hooks system is unstable ([#13155](https://github.com/anthropics/claude-code/issues/13155), [#11544](https://github.com/anthropics/claude-code/issues/11544))
- `type: "prompt"` hooks are silently ignored in plugins
- Hooks and Skills perform duplicate roles
- Excessive Stop hook triggering degrades user experience

### 1.2 Previous Structure (Duplicate)

```
Hooks (Unstable)        Skills (Stable)
─────────────────────────────────────────
PreToolUse hook    ←→   task-classification skill
PostToolUse hook   ←→   bkit-rules skill
Stop hook          ←→   (unnecessary)
PreCompact hook    ←→   (unnecessary)
```

---

## 2. Design Decisions

### 2.1 Principles

- **Simplification**: Remove duplicates, keep only stable approaches
- **Skills First**: Use Skills/Rules instead of Hooks for same functionality
- **Keep SessionStart Only**: Session start context injection is useful

### 2.2 Change Summary

| Component | Before | After |
|-----------|--------|-------|
| SessionStart hook | Keep | **Keep** |
| PreToolUse hook | prompt type | **Delete** |
| PostToolUse hook | prompt type | **Delete** |
| Stop hook | command type | **Delete** |
| SubagentStop hook | command type | **Delete** |
| PreCompact hook | prompt type | **Delete** |
| task-classification skill | Keep | **Keep** |
| bkit-rules skill | Keep | **Keep** |

---

## 3. Modified Files

### 3.1 Deleted

```
.claude/hooks/stop-hook.sh
.claude/hooks/subagent-stop-hook.sh
hooks/stop-hook.sh
hooks/subagent-stop-hook.sh
```

### 3.2 Modified

#### `.claude/settings.json`

**Before:**
```json
{
  "hooks": {
    "SessionStart": [...],
    "PreToolUse": [...],
    "PostToolUse": [...],
    "Stop": [...],
    "PreCompact": [...],
    "SubagentStop": [...]
  }
}
```

**After:**
```json
{
  "hooks": {
    "SessionStart": [
      {
        "once": true,
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/session-start.sh",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

#### `hooks/hooks.json`

**Before:**
```json
{
  "hooks": {
    "PreToolUse": [...],
    "PostToolUse": [...],
    "Stop": [...],
    "SubagentStop": [...],
    "PreCompact": [...]
  }
}
```

**After:**
```json
{
  "description": "bkit Vibecoding Kit - Hooks disabled for stability",
  "hooks": {}
}
```

### 3.3 Retained

```
.claude/hooks/session-start.sh        # Session start context
skills/task-classification/SKILL.md   # PDCA classification (replaces hooks)
skills/bkit-rules/SKILL.md            # PDCA rules (replaces hooks)
```

---

## 4. Feature Replacement Mapping

| Deleted Hook | Replacement |
|--------------|-------------|
| PreToolUse (Write\|Edit) | `task-classification` skill auto-triggers |
| PostToolUse (Write) | `bkit-rules` skill PDCA Auto-Apply Rules |
| PostToolUse (git commit) | User invokes `/pdca-status` as needed |
| Stop | Deleted (unnecessary - Claude stops naturally) |
| SubagentStop | Deleted (unnecessary) |
| PreCompact | Deleted (Claude default behavior sufficient) |

---

## 5. Rollback Plan

When Claude Code Hooks stabilize ([#13155](https://github.com/anthropics/claude-code/issues/13155) resolved):

1. Re-introduce hooks using `type: "command"` approach
2. Utilize `additionalContext` for context injection
3. Gradual re-activation based on this design document

---

## 6. References

- [HOOKS-FIX-PLAN-2026-01-19.md](../03-analysis/HOOKS-FIX-PLAN-2026-01-19.md)
- [CLAUDE-CODE-HOOKS-ANALYSIS.md](../03-analysis/CLAUDE-CODE-HOOKS-ANALYSIS.md)
- [GitHub #13155 - Prompt hooks ignored](https://github.com/anthropics/claude-code/issues/13155)
- [GitHub #11544 - Hooks not loading](https://github.com/anthropics/claude-code/issues/11544)
