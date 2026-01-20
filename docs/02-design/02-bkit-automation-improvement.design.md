# bkit 자동화 고도화 상세 설계서

> **Version**: 1.2.0
> **Date**: 2026-01-20
> **Status**: Draft
> **Related Plan**: [BKIT-AUTOMATION-IMPROVEMENT-PLAN.md](../01-plan/BKIT-AUTOMATION-IMPROVEMENT-PLAN.md)

---

## 1. 개요

### 1.1 목적

이 문서는 bkit 플러그인의 자동화 기능 복원 및 고도화를 위한 상세 설계를 제공합니다.
현재 구현된 모든 컴포넌트(agents, commands, skills, hooks, scripts, templates)의 As-Is 분석과
Claude Code v2.1.12의 Frontmatter Hooks를 활용한 To-Be 설계를 포함합니다.

### 1.2 배경

- **v1.1.4**: Hooks 시스템 불안정으로 인해 대부분의 hooks 비활성화
- **손실된 기능**: PDCA 자동 적용, 작업 분류, 설계-구현 연동 (~80% 자동화 손실)
- **해결 방안**: Skills/Agents Frontmatter Hooks (v2.1.0+) 활용

### 1.3 분석 범위

| 컴포넌트 | 파일 수 | 분석 완료 |
|----------|---------|----------|
| Agents | 11 | ✅ |
| Commands | 18 | ✅ |
| Skills | 25 | ✅ |
| Hooks | 3 configs | ✅ |
| Scripts | 2 | ✅ |
| Templates | 17 | ✅ |

---

## 2. 컴포넌트별 상세 분석

### 2.1 Agents (11개)

#### 2.1.1 현재 상태 (As-Is)

| Agent | Model | Hooks 유무 | Skills 연동 | 자동 트리거 |
|-------|-------|------------|-------------|-------------|
| bkend-expert | sonnet | ❌ | dynamic | 수동 |
| code-analyzer | opus | ✅ PreToolUse | analysis-patterns, document-standards | /pdca-analyze |
| design-validator | opus | ❌ | document-standards | /pdca-design |
| enterprise-expert | opus | ❌ | ai-native-development, enterprise, monorepo | 수동 |
| gap-detector | opus | ❌ | analysis-patterns, pdca-methodology | /pdca-analyze |
| infra-architect | opus | ❌ | enterprise | 수동 |
| pdca-iterator | sonnet | ❌ | evaluator-optimizer, analysis-patterns | /pdca-iterate |
| pipeline-guide | sonnet | ❌ | development-pipeline | /pipeline-* |
| qa-monitor | haiku | ❌ | zero-script-qa | /zero-script-qa |
| report-generator | haiku | ❌ | document-standards, pdca-methodology | /pdca-report |
| starter-guide | sonnet | ❌ | starter | 수동 |

**핵심 발견**:
- **Hook 구현**: 1/11 (9%) - code-analyzer만 PreToolUse hook 보유
- **Read-Only Agents**: code-analyzer, design-validator, gap-detector, pipeline-guide
- **Model 분포**: opus (6), sonnet (4), haiku (1)

#### 2.1.2 목표 상태 (To-Be)

| Agent | 추가할 Hooks | 목적 |
|-------|-------------|------|
| gap-detector | PostToolUse | 매치율 < 70%일 때 pdca-iterator 자동 트리거 |
| design-validator | PreToolUse | docs/02-design/ 새 파일 감지 시 자동 검증 |
| qa-monitor | PostToolUse | CRITICAL 이슈 발견 시 pdca-iterator 트리거 |
| pipeline-guide | SessionStart | 사용자 경험 수준 자동 감지 |
| pdca-iterator | PreToolUse | evaluator 가용성 검증 |
| bkend-expert | PreToolUse | bkend.ai 설정 검증 |
| infra-architect | PreToolUse | Terraform plan 검증 |
| report-generator | PreToolUse | PDCA artifacts 자동 수집 |

#### 2.1.3 수정 상세 - gap-detector.md

**Before** (현재):
```yaml
---
name: gap-detector
model: opus
tools:
  - Read
  - Glob
  - Grep
  - Task
skills:
  - analysis-patterns
  - pdca-methodology
description: |
  Agent that detects gaps between design documents and actual implementation.
  ...
---
```

**After** (목표):
```yaml
---
name: gap-detector
model: opus
tools:
  - Read
  - Glob
  - Grep
  - Task
skills:
  - analysis-patterns
  - pdca-methodology
hooks:
  PostToolUse:
    - matcher: "Write"
      hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/scripts/gap-detector-post.sh"
description: |
  Agent that detects gaps between design documents and actual implementation.
  ...
---
```

**신규 스크립트** `scripts/gap-detector-post.sh`:
```bash
#!/bin/bash
# gap-detector PostToolUse hook
# 매치율이 70% 미만일 경우 pdca-iterator 트리거 안내

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# 분석 보고서 파일인지 확인
if [[ "$FILE_PATH" == *".analysis.md" ]]; then
    # 매치율 추출 시도 (보고서 작성 후)
    cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "📊 Gap Analysis 완료. 매치율이 70% 미만인 경우 /pdca-iterate를 실행하여 자동 개선을 수행하세요."}}
EOF
else
    echo '{}'
fi
```

---

### 2.2 Commands (18개)

#### 2.2.1 현재 상태 (As-Is)

| 카테고리 | Commands | 자동화 수준 |
|----------|----------|-------------|
| **Init** | init-starter, init-dynamic, init-enterprise | 낮음 (수동) |
| **PDCA** | pdca-plan, pdca-design, pdca-analyze, pdca-iterate, pdca-report, pdca-status, pdca-next | 중간 |
| **Pipeline** | pipeline-start, pipeline-status, pipeline-next | 낮음 |
| **Setup** | setup-claude-code, upgrade-claude-code, upgrade-level | 높음 |
| **QA** | zero-script-qa | 높음 |
| **Learning** | learn-claude-code | 낮음 |

**핵심 발견**:
- **모든 Commands**: Hook 미정의 (0/18)
- **자동화 잠재력 1순위**: pdca-iterate, setup-claude-code, zero-script-qa
- **Tool 사용 빈도**: Read (9), Write (9), Glob (9), Bash (4)

#### 2.2.2 Commands는 유지 (No Change)

**근거** (이전 조사 결과):
1. Commands는 명시적 워크플로우 제공 (PDCA 1→2→3→4 순서)
2. Skills는 자동 발견 기반 (순서 개념 없음)
3. v2.1.3 "merge"는 내부 도구 통합일 뿐, 개념 분리는 유지
4. Commands 제거 시 사용자 명시적 호출 불가

---

### 2.3 Skills (25개)

#### 2.3.1 현재 상태 (As-Is)

| 카테고리 | Skills | Hook 유무 |
|----------|--------|-----------|
| **Core Framework** | bkit-rules, bkit-templates, pdca-methodology | ❌ |
| **Pipeline Phases** | phase-1~9 (9개) + development-pipeline | ❌ |
| **Domain** | starter, dynamic, enterprise, mobile-app, desktop-app 등 (13개) | 1개만 ✅ |

**핵심 발견**:
- **Hook 구현**: 1/25 (4%) - zero-script-qa만 PreToolUse + Stop hook 보유
- **user-invocable: true**: pdca-methodology, development-pipeline
- **context: fork**: analysis-patterns, evaluator-optimizer, zero-script-qa

#### 2.3.2 목표 상태 (To-Be) - 우선순위별

**Priority 1 - Critical Path Automation**:

| Skill | 추가할 Hooks | 목적 |
|-------|-------------|------|
| bkit-rules | PreToolUse (Write\|Edit) | PDCA 단계 감지 및 규칙 적용 |
| task-classification | PreToolUse (Write\|Edit) | 작업 분류 자동화 |
| development-pipeline | Stop | 다음 단계 안내 |

**Priority 2 - Phase Automation**:

| Skill | 추가할 Hooks | 목적 |
|-------|-------------|------|
| phase-4-api | Stop | API 구현 후 Zero Script QA 안내 |
| phase-6-ui-integration | PostToolUse | 레이어 분리 검증 |
| phase-8-review | Stop | 품질 리뷰 보고서 생성 |
| phase-9-deployment | PreToolUse | 환경 변수 검증 |

**Priority 3 - Quality Assurance**:

| Skill | 추가할 Hooks | 목적 |
|-------|-------------|------|
| phase-2-convention | PreToolUse | 코드 스타일 검증 |
| phase-5-design-system | PostToolUse | 디자인 토큰 일관성 검증 |
| analysis-patterns | Stop | Gap 분석 보고서 자동 생성 |

#### 2.3.3 수정 상세 - bkit-rules Skill

**Before** (현재 `.claude/skills/bkit-rules/SKILL.md`):
```yaml
---
name: bkit-rules
description: |
  Core rules for bkit plugin. PDCA methodology, level detection, agent auto-triggering, and code quality standards.
  These rules are automatically applied to ensure consistent AI-native development.

  Triggers: bkit, PDCA, 개발, develop, implement, 기능, feature, 버그, bug,
  코드, code, 설계, design, 문서, document
---
```

**After** (목표):
```yaml
---
name: bkit-rules
description: |
  Core rules for bkit plugin. PDCA methodology, level detection, agent auto-triggering, and code quality standards.
  These rules are automatically applied to ensure consistent AI-native development.

  Triggers: bkit, PDCA, 개발, develop, implement, 기능, feature, 버그, bug,
  코드, code, 설계, design, 문서, document
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/scripts/pdca-pre-write.sh"
  PostToolUse:
    - matcher: "Write"
      hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/scripts/pdca-post-write.sh"
---
```

---

### 2.4 Hooks Configuration

#### 2.4.1 현재 상태 (As-Is)

| 설정 파일 | 활성 Hooks | 비활성 이유 |
|-----------|------------|-------------|
| `/hooks/hooks.json` | ❌ 모두 비활성 | GitHub #13155 |
| `.claude/settings.json` | SessionStart만 | 안정성 우선 |
| `.claude/settings.local.json` | Hook 없음 | 권한 설정만 |

**비활성화된 Hooks**:
- PreToolUse (Write|Edit) - `type: "prompt"` → 무시됨
- PostToolUse (Write) - `type: "prompt"` → 무시됨
- Stop - JSON 형식 오류
- SubagentStop - JSON 형식 오류
- PreCompact - `type: "prompt"` → 무시됨

#### 2.4.2 목표 상태 (To-Be)

**전략 변경**:
- Global hooks (`hooks/hooks.json`) → **유지 비활성**
- Skills/Agents Frontmatter Hooks → **신규 활용**

**이유**:
1. `type: "prompt"`가 플러그인에서 무시됨 (#13155 미해결)
2. Skills Frontmatter Hooks는 `type: "command"`로 안정적 동작
3. 스코프 제한으로 과도한 트리거 방지

---

### 2.5 Scripts (2개 + 신규)

#### 2.5.1 현재 스크립트

| 스크립트 | 라인 수 | 용도 |
|----------|---------|------|
| `sync-folders.sh` | 424 | .claude/ ↔ root 동기화 |
| `validate-plugin.sh` | 653 | 플러그인 구조 검증 |

#### 2.5.2 신규 스크립트 (To-Be)

| 스크립트 | 용도 | 호출 위치 |
|----------|------|-----------|
| `pdca-pre-write.sh` | Write/Edit 전 PDCA 단계 감지 | bkit-rules PreToolUse |
| `pdca-post-write.sh` | Write 후 설계 동기화 안내 | bkit-rules PostToolUse |
| `gap-detector-post.sh` | Gap 분석 후 Iterator 안내 | gap-detector PostToolUse |
| `task-classify.sh` | 작업 분류 (Quick Fix ~ Major Feature) | task-classification PreToolUse |

---

### 2.6 Templates (17개)

#### 2.6.1 현재 상태

| 카테고리 | 파일 수 | 자동 생성 지원 |
|----------|---------|----------------|
| PDCA Templates | 7 | ✅ via /pdca-* |
| Pipeline Templates | 10 | 부분적 |

**주요 템플릿**:
- `plan.template.md` - 기획 문서
- `design.template.md` - 설계 문서
- `analysis.template.md` - 분석 보고서
- `report.template.md` - 완료 보고서
- `iteration-report.template.md` - 반복 개선 보고서

#### 2.6.2 변경 없음 (No Change)

템플릿은 현재 구조 유지. Hook 개선으로 자동 생성 빈도 증가 예상.

---

## 3. 파일별 수정 명세

### 3.1 신규 생성 파일

| 파일 경로 | 용도 |
|-----------|------|
| `scripts/pdca-pre-write.sh` | PreToolUse hook 스크립트 |
| `scripts/pdca-post-write.sh` | PostToolUse hook 스크립트 |
| `scripts/gap-detector-post.sh` | Gap 분석 후 안내 스크립트 |
| `scripts/task-classify.sh` | 작업 분류 스크립트 |

### 3.2 수정 파일 (Priority 1)

| 파일 | 수정 내용 |
|------|----------|
| `.claude/skills/bkit-rules/SKILL.md` | hooks 섹션 추가 |
| `.claude/skills/task-classification/SKILL.md` | hooks 섹션 추가 |
| `.claude/skills/development-pipeline/SKILL.md` | Stop hook 추가 |
| `.claude/agents/gap-detector.md` | PostToolUse hook 추가 |

### 3.3 수정 파일 (Priority 2)

| 파일 | 수정 내용 |
|------|----------|
| `.claude/skills/phase-4-api/SKILL.md` | Stop hook 추가 |
| `.claude/skills/phase-6-ui-integration/SKILL.md` | PostToolUse hook 추가 |
| `.claude/skills/phase-8-review/SKILL.md` | Stop hook 추가 |
| `.claude/skills/phase-9-deployment/SKILL.md` | PreToolUse hook 추가 |

### 3.4 수정 파일 (Priority 3)

| 파일 | 수정 내용 |
|------|----------|
| `.claude/skills/phase-2-convention/SKILL.md` | PreToolUse hook 추가 |
| `.claude/skills/phase-5-design-system/SKILL.md` | PostToolUse hook 추가 |
| `.claude/skills/analysis-patterns/SKILL.md` | Stop hook 추가 |
| `.claude/agents/design-validator.md` | PreToolUse hook 추가 |
| `.claude/agents/qa-monitor.md` | PostToolUse hook 추가 |

---

## 4. 스크립트 상세 설계

### 4.1 pdca-pre-write.sh

```bash
#!/bin/bash
# scripts/pdca-pre-write.sh
# Purpose: Detect PDCA phase and provide guidance before Write/Edit

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')

# Skip non-source files
if [[ ! "$FILE_PATH" == src/* ]] && [[ ! "$FILE_PATH" == lib/* ]] && [[ ! "$FILE_PATH" == app/* ]]; then
    echo '{}'
    exit 0
fi

# Extract feature name from path
FEATURE=$(echo "$FILE_PATH" | sed -n 's/.*\/\([^\/]*\)\/[^\/]*$/\1/p')
if [ -z "$FEATURE" ]; then
    FEATURE=$(basename "$(dirname "$FILE_PATH")")
fi

# Check for design document
DESIGN_DOC="docs/02-design/features/${FEATURE}.design.md"
PLAN_DOC="docs/01-plan/features/${FEATURE}.plan.md"

if [ -f "$DESIGN_DOC" ]; then
    # Design exists - provide context
    cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "📋 PDCA 알림: 이 파일은 ${FEATURE} 기능에 속합니다.\n\n설계 문서: ${DESIGN_DOC}\n\n구현 시 설계 문서를 참조하세요. 구현 완료 후 /pdca-analyze ${FEATURE}로 Gap 분석을 수행하세요."}}
EOF
elif [ -f "$PLAN_DOC" ]; then
    # Plan exists but no design
    cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "⚠️ PDCA 알림: ${FEATURE} 기능의 기획 문서는 있지만 설계 문서가 없습니다.\n\n/pdca-design ${FEATURE} 명령으로 설계 문서를 먼저 작성하는 것을 권장합니다."}}
EOF
else
    # No PDCA docs - check if this is a quick fix
    echo '{}'
fi
```

### 4.2 pdca-post-write.sh

```bash
#!/bin/bash
# scripts/pdca-post-write.sh
# Purpose: Guide next steps after Write operation

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')

# Skip non-source files
if [[ ! "$FILE_PATH" == src/* ]] && [[ ! "$FILE_PATH" == lib/* ]] && [[ ! "$FILE_PATH" == app/* ]]; then
    echo '{}'
    exit 0
fi

# Extract feature name
FEATURE=$(echo "$FILE_PATH" | sed -n 's/.*\/\([^\/]*\)\/[^\/]*$/\1/p')
if [ -z "$FEATURE" ]; then
    FEATURE=$(basename "$(dirname "$FILE_PATH")")
fi

# Check if design doc exists for gap analysis suggestion
DESIGN_DOC="docs/02-design/features/${FEATURE}.design.md"

if [ -f "$DESIGN_DOC" ]; then
    cat << EOF
{"hookSpecificOutput": {"additionalContext": "✅ ${FILE_PATH} 작성 완료.\n\n구현이 완료되면 /pdca-analyze ${FEATURE}를 실행하여 설계-구현 일치율을 확인하세요."}}
EOF
else
    echo '{}'
fi
```

### 4.3 task-classify.sh

```bash
#!/bin/bash
# scripts/task-classify.sh
# Purpose: Classify task type and apply appropriate PDCA guidance

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // ""')

# Calculate content size (rough estimation)
CONTENT_LENGTH=${#CONTENT}

# Classification thresholds
QUICK_FIX_THRESHOLD=50       # < 50 chars = typo, comment
MINOR_CHANGE_THRESHOLD=200   # < 200 chars = small fix
FEATURE_THRESHOLD=1000       # < 1000 chars = single feature

if [ "$CONTENT_LENGTH" -lt "$QUICK_FIX_THRESHOLD" ]; then
    # Quick Fix - no PDCA needed
    cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "🔧 Quick Fix로 분류됨 (${CONTENT_LENGTH}자). PDCA 문서 불필요."}}
EOF
elif [ "$CONTENT_LENGTH" -lt "$MINOR_CHANGE_THRESHOLD" ]; then
    # Minor Change - optional PDCA
    cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "📝 Minor Change로 분류됨 (${CONTENT_LENGTH}자). 필요시 /pdca-status로 현황을 확인하세요."}}
EOF
elif [ "$CONTENT_LENGTH" -lt "$FEATURE_THRESHOLD" ]; then
    # Feature - PDCA recommended
    cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "🎯 Feature로 분류됨 (${CONTENT_LENGTH}자). 설계 문서 작성을 권장합니다.\n\n/pdca-plan [feature-name] 또는 /pdca-design [feature-name]을 먼저 실행하세요."}}
EOF
else
    # Major Feature - PDCA required
    cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "🚀 Major Feature로 분류됨 (${CONTENT_LENGTH}자). PDCA 문서가 필수입니다.\n\n/pdca-plan [feature-name]으로 기획부터 시작하세요."}}
EOF
fi
```

---

## 5. 구현 순서

### Phase 1: 핵심 스크립트 생성 (Day 1)

1. `scripts/pdca-pre-write.sh` 생성
2. `scripts/pdca-post-write.sh` 생성
3. `scripts/task-classify.sh` 생성
4. 스크립트 실행 권한 부여

### Phase 2: Priority 1 Skills 수정 (Day 1-2)

1. `bkit-rules/SKILL.md` hooks 추가
2. `task-classification/SKILL.md` hooks 추가
3. `development-pipeline/SKILL.md` Stop hook 추가

### Phase 3: Priority 1 Agent 수정 (Day 2)

1. `gap-detector.md` PostToolUse hook 추가
2. `scripts/gap-detector-post.sh` 생성

### Phase 4: 테스트 및 검증 (Day 2-3)

1. 단위 테스트 (각 스크립트)
2. 통합 테스트 (Skill 로드 시 hook 동작)
3. E2E 테스트 (실제 개발 시나리오)

### Phase 5: Priority 2-3 적용 (Day 3-5)

1. phase-4-api, phase-6-ui-integration, phase-8-review, phase-9-deployment
2. phase-2-convention, phase-5-design-system, analysis-patterns
3. design-validator, qa-monitor agents

### Phase 6: 동기화 및 배포 (Day 5)

1. `scripts/sync-folders.sh` 실행
2. `scripts/validate-plugin.sh`로 검증
3. 버전 업데이트 (v1.2.0)

---

## 6. 예상 결과

### 6.1 자동화 수준 변화

| 컴포넌트 | As-Is | To-Be | 개선율 |
|----------|-------|-------|--------|
| Agents (hooks) | 9% (1/11) | 64% (7/11) | +55%p |
| Skills (hooks) | 4% (1/25) | 44% (11/25) | +40%p |
| 전체 자동화 | ~20% | ~80% | +60%p |

### 6.2 복원되는 기능

1. **PDCA 자동 적용**: Write/Edit 시 설계 문서 연동
2. **작업 분류**: 변경 규모에 따른 PDCA 가이드
3. **Gap 분석 연동**: 매치율 기반 자동 개선 안내
4. **Pipeline 단계 안내**: 완료 시 다음 단계 가이드

### 6.3 위험 요소 및 대응

| 위험 | 확률 | 대응 |
|------|------|------|
| Frontmatter hooks 미동작 | 중 | `type: "command"` 필수 사용 |
| 스크립트 타임아웃 | 낮 | 5초 내 완료 설계 |
| 과도한 컨텍스트 | 중 | 짧고 핵심적인 메시지 |

---

## 7. 롤백 계획

문제 발생 시:

1. `git revert` 또는 `git checkout v1.1.4`
2. hooks 섹션 제거 후 재배포
3. SessionStart hook만 유지 (현재 안정 상태)

---

## 8. Phase 3: Semantic Matching 강화 상세 설계

### 8.1 목표

사용자가 에이전트/스킬 이름을 몰라도 자연어 입력만으로 자동 활성화되도록 description을 강화합니다.

### 8.2 현재 상태 분석 (As-Is)

#### 8.2.1 Agents Description 품질 분석

| Agent | Triggers 유무 | "Use proactively" | "Do NOT use" | 다국어 | 등급 |
|-------|--------------|-------------------|--------------|--------|------|
| bkend-expert | ✅ | ❌ | ❌ | ✅ (4) | B |
| code-analyzer | ✅ | ❌ | ❌ | ✅ (3) | B |
| design-validator | ✅ | ❌ | ❌ | ✅ (3) | B |
| enterprise-expert | ✅ | ❌ | ❌ | ✅ (4) | B |
| gap-detector | ✅ | ❌ | ❌ | ✅ (4) | B |
| infra-architect | ✅ | ❌ | ❌ | ✅ (3) | B |
| pdca-iterator | ✅ | ❌ | ❌ | ✅ (4) | B |
| pipeline-guide | ✅ | ❌ | ❌ | ✅ (4) | B |
| qa-monitor | ✅ | ❌ | ❌ | ✅ (4) | B |
| report-generator | ✅ | ❌ | ❌ | ✅ (4) | B |
| starter-guide | ✅ | ❌ | ❌ | ✅ (4) | B |

**발견 사항**: 11/11 agents가 B등급. "Use proactively when" 및 "Do NOT use" 패턴 누락.

#### 8.2.2 Skills Description 품질 분석

| 등급 | 기준 | 개수 | 해당 Skills |
|------|------|------|-------------|
| A | Triggers + "Use when" + "Do NOT use" | 6 | bkit-rules, starter, task-classification, pdca-methodology, development-pipeline, analysis-patterns |
| B | Triggers만 있음 | 13 | bkit-templates, phase-1~9, document-standards 등 |
| C | Triggers 없음 | 6 | 일부 domain skills |

**발견 사항**: 19/25 skills (76%)가 개선 필요.

### 8.3 목표 상태 (To-Be)

#### 8.3.1 Description 표준 패턴

모든 Agents와 Skills의 description에 다음 패턴 적용:

```yaml
description: |
  [역할 한 줄 설명]
  [상세 설명 2-3문장]

  Use proactively when [활성화 조건].

  Triggers: [영어 키워드], [한국어], [일본어], [중국어]

  Do NOT use for: [제외 조건]
```

#### 8.3.2 Agent별 개선 명세

| Agent | 추가할 "Use proactively when" | 추가할 "Do NOT use" |
|-------|------------------------------|---------------------|
| starter-guide | user is a beginner, first time using Claude Code, or asks simple questions | experienced users, enterprise projects |
| bkend-expert | user mentions login, signup, authentication, database, or BaaS | static websites, infrastructure tasks |
| enterprise-expert | user discusses microservices, kubernetes, terraform, or enterprise architecture | simple projects, starter level |
| gap-detector | user requests comparison, verification, or gap analysis between design and implementation | documentation-only tasks |
| pipeline-guide | user asks about development order, what to do first, or starts a new project | ongoing implementation work |
| pdca-iterator | user requests auto-fix, iteration, or optimization of implementation | initial development, research |
| design-validator | user creates or modifies design documents | implementation code |
| code-analyzer | user requests code review, quality check, or security scan | design documents |
| qa-monitor | user requests testing or QA using Docker logs | unit testing, test script writing |
| report-generator | user completes PDCA cycle or requests completion report | ongoing work |
| infra-architect | user discusses AWS, Kubernetes, Terraform, or infrastructure | frontend development |

#### 8.3.3 Triggers 확장 매트릭스

| Agent/Skill | 현재 Triggers | 추가 Triggers |
|-------------|--------------|---------------|
| starter-guide | beginner, 초보자 | 처음, 간단한, simple, easy, first time, 入門, 初学者 |
| bkend-expert | bkend, auth | 로그인, 회원가입, firebase, supabase, データベース, 数据库 |
| gap-detector | gap analysis | 비교해, 확인해, 차이, 일치, 対比, 比较 |
| pipeline-guide | pipeline | 순서, 뭘 먼저, 어디서부터, where to start, 何から, 从哪里开始 |
| pdca-iterator | iterate, optimize | 자동 수정, 반복 개선, 고쳐, 自動修正, 自动修复 |

### 8.4 수정 대상 파일

**Priority 1 (Critical Path)**:
1. `agents/starter-guide.md`
2. `agents/bkend-expert.md`
3. `agents/gap-detector.md`
4. `agents/pipeline-guide.md`
5. `agents/pdca-iterator.md`

**Priority 2 (Enhancement)**:
6. `agents/design-validator.md`
7. `agents/code-analyzer.md`
8. `agents/enterprise-expert.md`
9. `agents/qa-monitor.md`
10. `agents/report-generator.md`
11. `agents/infra-architect.md`

**Skills (19개)**:
- 13개 B등급 skills에 "Use when" + "Do NOT use" 추가
- 6개 C등급 skills에 Triggers 추가

### 8.5 수정 예시

**Before** (현재 `agents/starter-guide.md`):
```yaml
---
name: starter-guide
description: |
  Friendly guide agent for non-developers and beginners.
  Explains in simple terms and provides step-by-step guidance for Starter level projects.

  Triggers: beginner, first project, new to coding, learn to code, simple website,
  portfolio, landing page, HTML CSS, 초보자, 입문, 처음, 코딩 배우기, 웹사이트 만들기,
  初心者, 入門, ウェブサイト作成, principiante, 新手, 学习编程
---
```

**After** (목표):
```yaml
---
name: starter-guide
description: |
  Friendly guide agent for non-developers and beginners.
  Explains in simple terms and provides step-by-step guidance for Starter level projects.

  Use proactively when user is a beginner, mentions "first time", asks about learning,
  or requests a simple static website without backend requirements.

  Triggers: beginner, first project, new to coding, learn to code, simple website,
  portfolio, landing page, HTML CSS, 초보자, 입문, 처음, 코딩 배우기, 웹사이트 만들기,
  初心者, 入門, ウェブサイト作成, principiante, 新手, 学习编程

  Do NOT use for: experienced developers, enterprise-level projects, backend development,
  microservices architecture, or complex fullstack applications.
---
```

---

## 9. Phase 4: Instructions 통합 상세 설계

### 9.1 문제 정의

**현재 구조**:
```
.claude/
├── instructions/          # ← 플러그인 구조에서 미지원!
│   ├── pdca-rules.md
│   ├── auto-trigger-agents.md
│   ├── level-detection.md
│   ├── code-quality-rules.md
│   ├── timeline-awareness.md
│   ├── zero-script-qa-rules.md
│   └── output-style-learning.md
├── skills/
├── agents/
└── commands/
```

**문제**: `.claude/instructions/` 폴더의 내용이 플러그인 로드 시 자동 적용되지 않음.
각 instruction 파일의 내용을 적절한 skills로 통합해야 함.

### 9.2 Instructions 파일 분석

| 파일 | 라인 수 | 핵심 내용 | 통합 대상 |
|------|---------|----------|----------|
| `pdca-rules.md` | 84 | PDCA 자동 적용 규칙, 템플릿 참조 | bkit-rules skill |
| `auto-trigger-agents.md` | 89 | Agent 자동 호출 규칙, skill-agent 연결 맵 | 각 agent description + bkit-rules |
| `level-detection.md` | 62 | Starter/Dynamic/Enterprise 감지 | **신규 level-detection skill** |
| `code-quality-rules.md` | 48 | DRY, SRP, 확장성, 하드코딩 금지 | bkit-rules skill |
| `timeline-awareness.md` | 144 | 문서 시간순서, 버전 충돌 처리 | document-standards skill |
| `zero-script-qa-rules.md` | 152 | 로그 기반 QA, 이슈 감지 규칙 | zero-script-qa skill |
| `output-style-learning.md` | 74 | 학습 모드 출력 스타일 | 제거 (SessionStart에서 필요시만) |

### 9.3 통합 계획

#### 9.3.1 bkit-rules Skill 통합 내용

**추가할 내용** (`skills/bkit-rules/SKILL.md`):

```markdown
## PDCA Auto-Apply Rules (from pdca-rules.md)

### 자동 적용 조건
- 새 기능 요청 시 → docs/02-design/ 확인
- 설계 문서 없으면 → 먼저 설계 제안
- 추측 금지 → 문서 확인 → 사용자에게 질문
- 구현 완료 후 → Gap Analysis 제안

### 템플릿 참조
- Plan: templates/plan.template.md
- Design: templates/design.template.md
- Analysis: templates/analysis.template.md
- Report: templates/report.template.md

## Code Quality Rules (from code-quality-rules.md)

### 핵심 원칙
1. **DRY (Don't Repeat Yourself)**: 중복 코드 3회 이상 → 함수/컴포넌트 추출
2. **SRP (Single Responsibility)**: 한 함수는 한 가지 일만
3. **확장성**: 새 기능 추가 시 기존 코드 최소 수정
4. **하드코딩 금지**: 설정값은 환경 변수 또는 config 파일

### 적용 시점
- Write/Edit 도구 사용 전 검토
- 리팩토링 제안 시 이 원칙 근거로 제시
```

#### 9.3.2 신규 level-detection Skill 생성

**파일**: `skills/level-detection/SKILL.md`

```yaml
---
name: level-detection
description: |
  Project level detection (Starter/Dynamic/Enterprise) for bkit.
  Automatically detects project complexity and applies appropriate guidance.

  Use proactively when starting a new project or when project structure is unclear.

  Triggers: level, starter, dynamic, enterprise, project type, complexity,
  레벨, 프로젝트 유형, 複雑度, 项目类型

  Do NOT use for: ongoing implementation where level is already determined.
---

# Level Detection Rules

## Detection Priority

1. **CLAUDE.md 명시**: `level: Starter|Dynamic|Enterprise`
2. **파일 구조 분석**:
   - `docker-compose.yml` 있음 → Dynamic 이상
   - `kubernetes/` 또는 `terraform/` 있음 → Enterprise
   - HTML/CSS만 있음 → Starter
3. **package.json 분석**:
   - bkend.ai SDK → Dynamic
   - Next.js only → Starter or Dynamic (API 유무로 판단)

## Level별 행동

| Level | 문서 복잡도 | Agent 추천 | 테스트 방식 |
|-------|-----------|-----------|-----------|
| Starter | 간소화 | starter-guide | 수동 브라우저 |
| Dynamic | 표준 | bkend-expert, pipeline-guide | Zero Script QA |
| Enterprise | 상세 | enterprise-expert, infra-architect | CI/CD + Zero Script QA |
```

#### 9.3.3 auto-trigger-agents 통합

각 Agent의 description에 자동 트리거 조건 명시 (Phase 3과 연계):

```yaml
# agents/gap-detector.md에 추가
description: |
  ...
  Auto-trigger conditions:
  - After /pdca-analyze command execution
  - When user mentions "compare design and implementation"
  - When design document exists but gap analysis report doesn't
```

#### 9.3.4 SessionStart Hook 강화

**현재** (`.claude/settings.json`):
```json
{
  "hooks": {
    "SessionStart": [{
      "type": "command",
      "command": "${PROJECT_DIR}/.claude/hooks/session-start.sh"
    }]
  }
}
```

**목표** (`hooks/session-start.sh` 개선):
```bash
#!/bin/bash
# hooks/session-start.sh - Enhanced SessionStart

cat << 'EOF'
{
  "additionalContext": "🎉 bkit Vibecoding Kit v1.2.0 활성화됨.

**PDCA 핵심 규칙 (자동 적용):**
- 기능 요청 → docs/02-design/ 확인 → 없으면 먼저 설계
- 추측 금지 → 문서 확인 → 질문
- 구현 완료 → Gap Analysis 제안

**Level 감지됨:** [자동 감지 결과]

**도움이 필요하면:**
- /learn-claude-code - Claude Code 학습
- /pdca-status - PDCA 진행 상황
- /pipeline-start - 개발 파이프라인 시작"
}
EOF
```

### 9.4 수정 대상 파일

| 파일 | 수정 내용 | 우선순위 |
|------|----------|----------|
| `skills/bkit-rules/SKILL.md` | pdca-rules + code-quality-rules 통합 | P0 |
| `skills/level-detection/SKILL.md` | **신규 생성** | P0 |
| `skills/document-standards/SKILL.md` | timeline-awareness 통합 | P1 |
| `skills/zero-script-qa/SKILL.md` | zero-script-qa-rules 통합 | P1 |
| `hooks/session-start.sh` | 강화된 가이드 추가 | P1 |
| 각 agents/*.md | auto-trigger 조건 명시 | P1 |

### 9.5 Instructions 폴더 처리

통합 완료 후:
1. `.claude/instructions/` 내용을 `.claude/instructions.bak/`로 백업
2. 또는 각 파일에 `# DEPRECATED: Merged into skills/xxx` 주석 추가
3. README 업데이트하여 통합 위치 안내

---

## 10. Phase 5: Templates 개선 상세 설계

### 10.1 목표

Level별 템플릿 자동 선택 및 변수 확장으로 문서 품질 향상.

### 10.2 현재 상태 분석

#### 10.2.1 기존 Templates 목록

| 디렉토리 | 파일 | 용도 |
|----------|------|------|
| `templates/` | plan.template.md | 기획 문서 |
| | design.template.md | 설계 문서 |
| | analysis.template.md | Gap 분석 보고서 |
| | report.template.md | 완료 보고서 |
| | iteration-report.template.md | 반복 개선 보고서 |
| | feature-plan.template.md | 기능별 기획 |
| | session-learning.template.md | 학습 세션 기록 |
| `templates/pipeline/` | phase-1-schema.template.md | 스키마 정의 |
| | phase-2-convention.template.md | 코딩 규칙 |
| | phase-3-mockup.template.md | UI 목업 |
| | phase-4-api.template.md | API 설계 |
| | phase-5-design-system.template.md | 디자인 시스템 |
| | phase-6-ui-integration.template.md | UI 통합 |
| | phase-7-seo-security.template.md | SEO/보안 |
| | phase-8-review.template.md | 코드 리뷰 |
| | phase-9-deployment.template.md | 배포 |
| | zero-script-qa.template.md | Zero Script QA |

#### 10.2.2 현재 템플릿 변수

```markdown
# 현재 사용 중인 변수
{feature}     - 기능 이름
{date}        - 날짜
{status}      - 문서 상태
```

### 10.3 목표 상태 (To-Be)

#### 10.3.1 확장된 템플릿 변수

```markdown
# 기본 변수
{feature}       - 기능 이름 (required)
{date}          - 생성일 (auto: YYYY-MM-DD)
{status}        - 상태 (default: Draft)

# 프로젝트 컨텍스트
{level}         - Starter | Dynamic | Enterprise (auto-detect)
{project}       - 프로젝트 이름 (from CLAUDE.md)
{version}       - 버전 (from package.json or CLAUDE.md)

# PDCA 연결
{related_plan}  - 관련 Plan 문서 경로
{related_design} - 관련 Design 문서 경로
{cycle}         - PDCA 사이클 번호 (default: 1)

# 메타데이터
{author}        - 작성자 (default: Claude + User)
{reviewers}     - 검토자 목록
```

#### 10.3.2 Level별 템플릿 분기

**Starter Level** (간소화):
```markdown
# {feature} 설계

> 생성일: {date}

## 목표
{goal}

## 구현
{implementation}

## 완료 기준
- [ ] 기능 동작
- [ ] 브라우저 테스트
```

**Dynamic Level** (표준):
```markdown
# {feature} 설계 문서

> **생성일**: {date}
> **상태**: {status}
> **레벨**: Dynamic
> **관련 Plan**: {related_plan}

## 1. 개요
### 1.1 목표
{goal}

### 1.2 범위
{scope}

## 2. 아키텍처
### 2.1 컴포넌트 구조
{architecture}

### 2.2 데이터 흐름
{data_flow}

## 3. API 설계
{api_design}

## 4. 완료 기준
- [ ] 기능 구현
- [ ] API 테스트 (Zero Script QA)
- [ ] Gap Analysis 통과
```

**Enterprise Level** (상세):
```markdown
# {feature} 상세 설계 문서

> **Version**: {version}
> **생성일**: {date}
> **상태**: {status}
> **레벨**: Enterprise
> **관련 Plan**: {related_plan}
> **검토자**: {reviewers}

## 1. 개요
### 1.1 목표
{goal}

### 1.2 범위
{scope}

### 1.3 비기능 요구사항
{non_functional}

## 2. 아키텍처
### 2.1 시스템 아키텍처
{system_architecture}

### 2.2 마이크로서비스 구조
{microservices}

### 2.3 데이터 흐름
{data_flow}

## 3. API 설계
### 3.1 Endpoints
{endpoints}

### 3.2 인증/인가
{auth}

## 4. 인프라
### 4.1 Kubernetes 리소스
{k8s_resources}

### 4.2 모니터링
{monitoring}

## 5. 보안
{security}

## 6. 완료 기준
- [ ] 기능 구현
- [ ] Unit Tests 통과
- [ ] Integration Tests 통과
- [ ] Zero Script QA 완료
- [ ] Security Scan 통과
- [ ] Gap Analysis > 90%
- [ ] 코드 리뷰 승인
```

#### 10.3.3 템플릿 자동 선택 로직

**스크립트**: `scripts/select-template.sh`

```bash
#!/bin/bash
# scripts/select-template.sh
# Usage: select-template.sh <template-type> <feature-name>

TEMPLATE_TYPE=$1  # plan, design, analysis, report
FEATURE_NAME=$2

# Level 감지
LEVEL="Dynamic"  # default
if [ -f "CLAUDE.md" ]; then
    DETECTED=$(grep -i "level:" CLAUDE.md | head -1 | awk '{print $2}')
    [ -n "$DETECTED" ] && LEVEL=$DETECTED
elif [ -d "kubernetes" ] || [ -d "terraform" ]; then
    LEVEL="Enterprise"
elif [ ! -f "docker-compose.yml" ] && [ ! -d "api" ]; then
    LEVEL="Starter"
fi

# 템플릿 경로 결정
TEMPLATE_DIR="templates"
case $LEVEL in
    Starter)
        TEMPLATE_FILE="${TEMPLATE_DIR}/${TEMPLATE_TYPE}-starter.template.md"
        ;;
    Enterprise)
        TEMPLATE_FILE="${TEMPLATE_DIR}/${TEMPLATE_TYPE}-enterprise.template.md"
        ;;
    *)
        TEMPLATE_FILE="${TEMPLATE_DIR}/${TEMPLATE_TYPE}.template.md"
        ;;
esac

# 폴백
[ ! -f "$TEMPLATE_FILE" ] && TEMPLATE_FILE="${TEMPLATE_DIR}/${TEMPLATE_TYPE}.template.md"

echo "$TEMPLATE_FILE"
```

### 10.4 수정 대상 파일

| 파일 | 수정 내용 | 우선순위 |
|------|----------|----------|
| `templates/design.template.md` | 변수 확장 | P1 |
| `templates/design-starter.template.md` | **신규 생성** (간소화) | P2 |
| `templates/design-enterprise.template.md` | **신규 생성** (상세) | P2 |
| `templates/plan.template.md` | 변수 확장 | P1 |
| `templates/analysis.template.md` | 변수 확장 | P1 |
| `scripts/select-template.sh` | **신규 생성** | P1 |

### 10.5 Pipeline 템플릿 개선

각 Phase 템플릿에 다음 표준 섹션 추가:

```markdown
## Phase 완료 체크리스트

### 필수
- [ ] {phase_specific_requirement_1}
- [ ] {phase_specific_requirement_2}

### 선택 (Level별)
- [ ] Starter: N/A
- [ ] Dynamic: {dynamic_requirement}
- [ ] Enterprise: {enterprise_requirement}

## 다음 단계

이 Phase가 완료되면 [Phase {next_phase}: {next_phase_name}](./phase-{next_phase}-{next_phase_slug}.template.md)로 진행하세요.
```

---

## 11. 통합 구현 순서 (Updated)

### Phase 1: 핵심 스크립트 생성 (Day 1)

```
□ scripts/pdca-pre-write.sh 생성
□ scripts/pdca-post-write.sh 생성
□ scripts/task-classify.sh 생성
□ scripts/select-template.sh 생성
□ 스크립트 실행 권한 부여
```

### Phase 2: Priority 1 Skills/Agents 수정 (Day 1-2)

```
□ skills/bkit-rules/SKILL.md에 hooks + instructions 통합
□ skills/task-classification/SKILL.md에 hooks 추가
□ skills/development-pipeline/SKILL.md에 Stop hook 추가
□ agents/gap-detector.md에 PostToolUse hook 추가
□ scripts/gap-detector-post.sh 생성
```

### Phase 3: Semantic Matching 강화 (Day 2-3)

```
□ 11개 agents description에 "Use proactively when" + "Do NOT use" 추가
□ 11개 agents에 Triggers 확장
□ 19개 skills에 "Use when" + "Do NOT use" 추가
□ 다국어 키워드 추가 (한/영/일/중)
```

### Phase 4: Instructions 통합 (Day 3-4)

```
□ skills/bkit-rules/SKILL.md에 pdca-rules + code-quality-rules 통합
□ skills/level-detection/SKILL.md 신규 생성
□ skills/document-standards/SKILL.md에 timeline-awareness 통합
□ skills/zero-script-qa/SKILL.md에 zero-script-qa-rules 통합
□ hooks/session-start.sh 강화
□ instructions/ 백업 또는 deprecation 표시
```

### Phase 5: Templates 개선 (Day 4-5)

```
□ templates/design.template.md 변수 확장
□ templates/design-starter.template.md 신규 생성
□ templates/design-enterprise.template.md 신규 생성
□ templates/plan.template.md 변수 확장
□ templates/analysis.template.md 변수 확장
□ scripts/select-template.sh 신규 생성
□ pipeline 템플릿에 체크리스트 추가
```

### Phase 6: 테스트 및 검증 (Day 5-6)

```
□ 단위 테스트 (각 스크립트)
□ 통합 테스트 (Skills/Agents hooks 동작)
□ Semantic matching 테스트 (자연어 입력)
□ Level 감지 테스트 (Starter/Dynamic/Enterprise)
□ 템플릿 자동 선택 테스트
□ E2E 테스트 (전체 PDCA 워크플로우)
```

### Phase 7: 동기화 및 배포 (Day 6-7)

```
□ scripts/sync-folders.sh 실행
□ scripts/validate-plugin.sh로 검증
□ 버전 업데이트 (v1.2.0)
□ CHANGELOG.md 업데이트
□ README.md 업데이트
```

---

## 12. 참고 자료

### 공식 문서
- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks)
- [Claude Code Skills](https://docs.anthropic.com/en/docs/claude-code/skills)
- [Claude Code Sub-agents](https://docs.anthropic.com/en/docs/claude-code/sub-agents)

### GitHub Issues
- [#13155 - Plugin prompt hooks ignored](https://github.com/anthropics/claude-code/issues/13155)
- [#13744 - PreToolUse exit 2 doesn't block Write/Edit](https://github.com/anthropics/claude-code/issues/13744)
- [#11544 - Hooks not loading](https://github.com/anthropics/claude-code/issues/11544)

### 관련 문서
- [BKIT-AUTOMATION-IMPROVEMENT-PLAN.md](../01-plan/BKIT-AUTOMATION-IMPROVEMENT-PLAN.md)
- [HOOKS-FIX-PLAN-2026-01-19.md](../03-analysis/HOOKS-FIX-PLAN-2026-01-19.md)
- [01-AI-NATIVE-TRANSFORMATION.md](../01-AI-NATIVE-TRANSFORMATION.md)

---

*Document Version: 1.2.0*
*Last Updated: 2026-01-20*
*Status: Design Phase - 구현 대기*
