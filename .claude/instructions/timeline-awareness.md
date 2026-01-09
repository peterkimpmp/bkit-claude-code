# Timeline Awareness Rules

> Claude Code recognizes document time order and versions, handling them appropriately.

---

## Document Timeline Recognition

### Phase Number Based Order

```
docs/
├── 00-requirement/    # Written first
├── 01-development/    # Written after requirements confirmed
├── 02-design/         # Continuously updated during development
├── 03-analysis/       # Written after implementation
└── 04-report/         # Written at cycle completion
```

### Filename Timeline Patterns

```
# Number prefix indicates order
01_system_architecture_design.md    # First
02_core_feature_design.md           # Second
03_api_spec.md                      # Third

# Date prefix indicates version
2024-12-01_initial_design.md
2024-12-15_improved_design.md       # More recent
```

---

## Document Status Recognition

### Using _INDEX.md

Check document status in each folder's `_INDEX.md`:

```markdown
## Document List

| Document | Status | Last Modified |
|----------|--------|---------------|
| architecture.md | ✅ Confirmed | 2024-12-01 |
| api-spec.md | 🔄 In Progress | 2024-12-10 |
| data-model.md | ⏸️ On Hold | 2024-11-20 |
```

### Status Meanings

| Status | Meaning | Claude Behavior |
|--------|---------|-----------------|
| ✅ Confirmed | Use as implementation reference | Follow as-is |
| 🔄 In Progress | Still being written | Notify of possible changes |
| ⏸️ On Hold | Temporarily paused | Reference only, request confirmation |
| ❌ Deprecated | No longer valid | Ignore |

---

## Version Conflict Handling

### When Multiple Versions of Same Content Exist

```
Rule: Reference only the latest version

1. Determine latest by date/number
2. Work based on latest version
3. Notify user when old version reference needed
```

### When Design vs Implementation Mismatch

```
Rule: Code is truth, suggest document update

1. Work based on code
2. "Design document differs from implementation."
3. "Would you like to update the document to match current implementation?"
```

---

## Changelog Management

### Change History Location

```
docs/04-report/changelog.md
```

### Change History Format

```markdown
## [Date] - Change Summary

### Added
- New feature A
- New feature B

### Changed
- Modified existing feature X

### Fixed
- Fixed bug Y

### Removed
- Deprecated feature Z
```

---

## PDCA Cycle Tracking

### Cycle Recording

Track PDCA cycle for each feature:

```markdown
## Feature: Login Feature

### Cycle 1 (2024-12-01 ~ 2024-12-05)
- Plan: docs/01-plan/login.plan.md
- Design: docs/02-design/login.design.md
- Analysis: docs/03-analysis/login-gap.md
- Report: docs/04-report/login-v1.md

### Cycle 2 (2024-12-10 ~ 2024-12-12)
- Improvements: Social login added
- ...
```

### Current Cycle Stage Determination

```
docs/01-plan/{feature}.md exists, no design → Plan stage
docs/02-design/{feature}.md exists, no implementation → Design complete, Do pending
Implementation exists, no analysis → Do complete, Check pending
docs/03-analysis/{feature}.md exists → Check complete
docs/04-report/{feature}.md exists → Cycle complete
```
