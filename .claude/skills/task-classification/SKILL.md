---
name: task-classification
description: |
  PDCA task classification for Write/Edit operations.
  Determines if task is Quick Fix, Minor Change, Feature, or Major Feature.
  Apply PDCA guidance based on classification before writing code.

  Use proactively when user requests code changes to determine appropriate PDCA level.

  Triggers: task-classification, PDCA check, write code, edit code, implement, create feature,
  add feature, fix bug, refactor, redesign, 코드 작성, 기능 구현, 기능 추가, 버그 수정,
  コード作成, 機能実装, バグ修正, 代码编写, 功能实现, 错误修复

  Do NOT use for: reading files, exploration, or non-code tasks.
user-invocable: false
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/scripts/task-classify.sh"
---

# Task Classification System

Classify user requests into 4 categories to apply appropriate PDCA guidance.

## Classification Criteria

### Quick Fix (No PDCA)

**Indicators:**
- Single file modification
- 10 lines or less change
- No logic changes
- Typo fixes, style tweaks

**Keywords:**
```
EN: fix, typo, correct, adjust, tweak
KO: 수정해줘, 고쳐줘, 바꿔줘, 오타, 변경해줘
JA: 修正, 直して, タイポ
ZH: 修复, 改一下, 错字
```

**Examples:**
- "Fix the typo in README"
- "Change button color"
- "Update config value"

### Minor Change (PDCA Lite)

**Indicators:**
- 1-3 files modified
- 10-50 lines change
- No new files created
- Existing logic improvement

**Keywords:**
```
EN: improve, refactor, enhance, optimize, update
KO: 개선해줘, 리팩토링, 최적화, 업데이트
JA: 改善, リファクタリング, 最適化
ZH: 改进, 重构, 优化
```

**Examples:**
- "Refactor the login function"
- "Fix a bug in existing feature"
- "Improve performance"

### Feature (Standard PDCA)

**Indicators:**
- New files required
- 50+ lines change
- New functionality added

**Keywords:**
```
EN: add, create, implement, build, new feature
KO: 추가해줘, 만들어줘, 구현해줘, 기능 추가
JA: 追加, 作って, 実装して, 新機能
ZH: 添加, 创建, 实现, 新功能
```

**Examples:**
- "Create login feature"
- "Add new API endpoint"
- "Implement dashboard page"

### Major Feature (Strict PDCA)

**Indicators:**
- Multiple modules affected
- Architecture changes
- Large scale refactoring

**Keywords:**
```
EN: redesign, migrate, architecture, overhaul, rewrite
KO: 재설계, 마이그레이션, 아키텍처, 전면 개편
JA: 再設計, マイグレーション, アーキテクチャ
ZH: 重新设计, 迁移, 架构, 全面改造
```

**Examples:**
- "Redesign authentication system"
- "Migrate to monorepo"
- "Overhaul state management"

## Classification Process

1. Detect keywords from user request
2. Estimate change scope (file count, line count)
3. Determine classification
4. Apply corresponding PDCA level

## PDCA Application by Classification

| Classification | PDCA Level | Action |
|----------------|------------|--------|
| Quick Fix | None | Execute immediately |
| Minor Change | Lite | Show 3-line summary, proceed |
| Feature | Standard | Check/create design doc |
| Major Feature | Strict | Require design, user confirmation |

## Ambiguous Request Handling

When classification is unclear, ask user:

```
Which scope describes your request?

1. Simple fix (bug fix, style change) → Quick Fix/Minor
2. Feature improvement (new feature, logic change) → Feature
3. Large scale change (redesign, architecture) → Major Feature
```
