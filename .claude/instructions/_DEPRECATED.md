# ⚠️ DEPRECATED - Instructions Folder

> **As of v1.2.0, this folder is deprecated.**
> All instructions have been migrated to skills with frontmatter hooks.

## Migration Map

| Instruction File | Migrated To |
|-----------------|-------------|
| `timeline-awareness.md` | `.claude/skills/document-standards/SKILL.md` |
| `zero-script-qa-rules.md` | `.claude/skills/zero-script-qa/SKILL.md` |
| `pdca-rules.md` | `.claude/skills/bkit-rules/SKILL.md` |
| `level-detection.md` | `.claude/skills/level-detection/SKILL.md` |
| `auto-trigger-agents.md` | `.claude/skills/bkit-rules/SKILL.md` |
| `code-quality-rules.md` | `.claude/skills/bkit-rules/SKILL.md` |
| `output-style-learning.md` | SessionStart hook in `settings.json` |

## Why Deprecated?

1. **Skills Frontmatter Hooks** (Claude Code v2.1.0+) provide the same functionality
2. **Better Organization**: Rules co-located with related skills
3. **Type Safety**: `type: "command"` hooks are more reliable than `type: "prompt"`
4. **Reduced Context Load**: Only relevant skills loaded per session

## Do NOT Delete

These files are kept for backward compatibility and reference.
They will be removed in a future major version.
