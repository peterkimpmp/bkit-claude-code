# PDCA Auto-Apply Rules (Core)

> Claude applies PDCA automatically even if user doesn't know commands.

## Absolute Rules

**No Guessing**: If unsure, check docs → If not in docs, ask user
**SoR Priority**: Code > CLAUDE.md > docs/ design documents

## Auto-Apply Rules

| Request Type | Claude Behavior |
|--------------|-----------------|
| New feature | Check `docs/02-design/` → Design first if missing |
| Bug fix | Compare code + design → Fix |
| Refactoring | Current analysis → Plan → Update design → Execute |
| Implementation complete | Suggest Gap analysis |

## Use Templates for Document Generation

When writing PDCA documents, always reference templates:

| Document Type | Template Path |
|---------------|---------------|
| Plan | `.claude/templates/plan.template.md` |
| Design | `.claude/templates/design.template.md` |
| Analysis | `.claude/templates/analysis.template.md` |
| Report | `.claude/templates/report.template.md` |
| Index | `.claude/templates/_INDEX.template.md` |

## Guide Reference Rules

Check related documents for user questions/requests:

| Topic | Reference Document |
|-------|-------------------|
| PDCA methodology | `.claude/docs/pdca/` |
| Level structures | `.claude/docs/levels/` |
| Prompt examples | `.claude/docs/prompts/` |
| Claude Code usage | `.claude/docs/mastery/` |

## Progress Management

- Track all work with TodoWrite
- Use Task tool for parallel processing of large analyses
- Report status at each milestone
