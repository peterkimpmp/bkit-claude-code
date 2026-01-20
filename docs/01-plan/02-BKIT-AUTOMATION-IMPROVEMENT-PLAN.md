# bkit 자동화 개선 계획 (v1.2.0)

> **목적**: Hooks 시스템의 불안정성을 우회하면서 설계 의도대로 자동화를 달성
> **작성일**: 2026-01-20
> **기반 버전**: Claude Code v2.1.12, bkit v1.1.4
> **상태**: Plan Phase

---

## 1. Executive Summary

### 1.1 배경

v1.1.4에서 hooks 시스템의 불안정성으로 인해 대부분의 hooks를 비활성화했습니다:
- PreToolUse, PostToolUse hooks → 플러그인에서 `type: "prompt"` 완전 무시 (#13155)
- Stop, SubagentStop hooks → JSON 형식 오류
- 결과: **설계 의도의 ~80% 자동화 기능 상실**

### 1.2 핵심 발견사항

Claude Code v2.1.x 조사 결과, **hooks를 대체할 수 있는 새로운 메커니즘**을 발견했습니다:

| 발견사항 | 버전 | 영향도 | 설명 |
|---------|------|--------|------|
| **Skills Frontmatter Hooks** | v2.1.0+ | 🔴 Critical | Skills 내에서 직접 hooks 정의 가능 |
| **Agents Frontmatter Hooks** | v2.1.0+ | 🔴 Critical | Agents 내에서 직접 hooks 정의 가능 |
| **PreToolUse additionalContext** | v2.1.9 | 🟡 High | Hook에서 모델에 컨텍스트 주입 가능 |
| **Commands-Skills 통합** | v2.1.3 | 🟡 High | 멘탈 모델 단순화 |
| **Hook 타임아웃 10분** | v2.1.3 | 🟢 Medium | 복잡한 검증 작업 가능 |

### 1.3 개선 목표

```
┌─────────────────────────────────────────────────────────────────┐
│                    bkit v1.2.0 개선 목표                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  현재 상태 (v1.1.4):                                            │
│  ├─ SessionStart hook만 활성화 (20%)                           │
│  ├─ 나머지 자동화 기능 비활성화 (80%)                          │
│  └─ 사용자가 명시적으로 명령어 실행 필요                        │
│                                                                 │
│  목표 상태 (v1.2.0):                                            │
│  ├─ Skills/Agents frontmatter hooks로 자동화 복원 (90%+)       │
│  ├─ Semantic matching으로 에이전트 자동 활성화                 │
│  └─ 사용자가 명령어 몰라도 자동으로 PDCA 적용                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. 조사 결과 종합

### 2.1 설계 의도 분석 (docs/00~03)

**bkit의 3가지 핵심 철학:**

| 철학 | 의미 | 현재 상태 | 목표 |
|------|------|----------|------|
| **Automation First** | 명령어 없이 자동 PDCA 적용 | ❌ 대부분 수동 | ✅ 자동화 복원 |
| **No Guessing** | 불확실하면 문서 확인 또는 질문 | ⚠️ 부분 동작 | ✅ 완전 동작 |
| **Docs = Code** | 설계 우선, 구현 나중 | ⚠️ 부분 동작 | ✅ 자동 강제 |

**Hooks에 의존하던 핵심 기능:**

| Hook | 원래 목표 | 현재 상태 | 대체 방안 |
|------|---------|----------|----------|
| SessionStart | 세션 시작 가이드 | ✅ 유지 | 유지 |
| PreToolUse (Write/Edit) | 설계 문서 확인 알림 | ❌ 비활성화 | Skills frontmatter hooks |
| PostToolUse (git commit) | PDCA 상태 업데이트 | ❌ 비활성화 | Skills frontmatter hooks |
| Stop | 작업 완료 체크리스트 | ❌ 비활성화 | Agents frontmatter hooks |
| UserPromptSubmit | 스마트 온보딩 | ❌ 제거됨 | Semantic matching 강화 |

### 2.2 Claude Code v2.1.x 신기능 분석

#### A. Skills Frontmatter Hooks (핵심 발견)

```yaml
# Skills에서 직접 hooks 정의 가능!
---
name: pdca-write-guard
description: |
  PDCA 설계 문서 확인 가드.
  파일 작성 전 설계 문서 존재 여부 확인.

  Triggers: code, develop, implement, feature, 코드, 개발, 구현
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/scripts/check-design-doc.sh"
          once: false  # 매번 실행
  PostToolUse:
    - matcher: "Write"
      hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/scripts/suggest-gap-analysis.sh"
---
```

**장점:**
- 플러그인의 hooks/hooks.json 대신 각 Skill에 분산 정의
- Skill 활성화 시에만 해당 hooks 실행 (범위 제한)
- `type: "command"`는 안정적으로 동작

#### B. Agents Frontmatter Hooks

```yaml
# Agents에서 직접 hooks 정의 가능!
---
name: gap-detector
description: |
  설계-구현 Gap 분석 전문가.
  Use proactively after implementation.
model: opus
skills:
  - analysis-patterns
  - pdca-methodology
hooks:
  Stop:
    - hooks:
      - type: command
        command: "$CLAUDE_PROJECT_DIR/scripts/pdca-checklist.sh"
---
```

**장점:**
- Agent 라이프사이클 동안만 hooks 실행
- Stop hook으로 작업 완료 검증 가능
- `type: "prompt"` 대신 `type: "command"` 사용으로 안정성 확보

#### C. PreToolUse additionalContext (v2.1.9)

```json
// Hook 출력에서 모델에 컨텍스트 주입
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "additionalContext": "⚠️ PDCA 알림: docs/02-design/login.design.md 설계 문서가 존재합니다. 설계에 따라 구현하세요."
  }
}
```

**활용:**
- PreToolUse에서 설계 문서 존재 여부 확인
- 존재하면 additionalContext로 Claude에게 알림
- Claude가 자연스럽게 설계 기반 구현 유도

#### D. Commands-Skills 통합 분석 (v2.1.3)

**v2.1.3의 "통합"이 의미하는 것:**
- **내부 tool만 통합됨** (SlashCommand tool → Skill tool로 병합)
- **사용 방식과 발견 메커니즘은 동일하게 유지**
- **파일 구조도 따로 관리됨**

> "Merged slash commands and skills, simplifying the mental model with no change in behavior"

**Commands vs Skills 핵심 차이점:**

| 구분 | **Commands** | **Skills** |
|------|-------------|-----------|
| **발견 방식** | 명시적 (`/command` 입력) | 자동 (Claude가 context 기반 선택) |
| **용도** | 명시적 프로세스 단계 | 배경 지식, 참고 자료 |
| **Context 로드** | 호출 시에만 | **모든 대화에 설명 프리로드** |
| **고유 기능** | `disable-model-invocation` | hooks, context fork |

**Commands를 제거하면 안 되는 이유:**

| 문제 | 설명 |
|------|------|
| **Context 폭증** | 18개 command가 skill로 변환되면, 모든 대화에 설명이 로드됨 |
| **프로세스 모호화** | `/pdca-plan`이 "자동 발견될 수 있는" 상태가 되어 UX 혼동 |
| **의도 불명확** | PDCA는 **순서가 있는 프로세스**인데, 자동 발견은 순서 개념이 없음 |
| **토큰 낭비** | 명시적 명령마다 자동 발견 기반이 되어 불필요한 토큰 소비 |

**공식 권장 사항 (code.claude.com):**

```
Use slash commands for:
- Quick, frequently used prompts
- Simple prompt snippets you use often
- Frequently used instructions that fit in one file

Use Skills for:
- Comprehensive capabilities with structure
- Complex workflows with multiple steps
- Capabilities requiring scripts or utilities
```

**결론: bkit의 현재 구조가 최적**

```
Commands (명시적 단계):        Skills (배경 지식):
├── /pdca-plan    → 1단계     ├── pdca-methodology
├── /pdca-design  → 2단계     ├── analysis-patterns
├── /pdca-analyze → 3단계     ├── phase-1-schema
└── /pdca-report  → 4단계     └── bkit-rules (hooks 포함)
```

### 2.3 GitHub 이슈 분석

**Hooks 안정성 이슈:**

| 이슈 | 문제 | 상태 | 영향 |
|------|------|------|------|
| #13155 | Plugin에서 `type: "prompt"` 무시 | Open | 🔴 Critical |
| #13744 | Exit code 2로 Write/Edit 차단 실패 | Open | 🟡 High |
| #11544 | settings.json hooks 로드 안 됨 | Open | 🟡 High |
| #6305 | PreToolUse/PostToolUse 실행 안 됨 | Open | 🟡 High |

**해결 전략:**
- `type: "prompt"` → `type: "command"` 전환
- hooks/hooks.json → Skills/Agents frontmatter hooks로 분산
- Exit code 의존 대신 additionalContext 활용

### 2.4 현재 .claude/ 구현 분석

**컴포넌트 현황:**

| 컴포넌트 | 개수 | 상태 | 개선 필요 |
|---------|------|------|----------|
| Agents | 10개 | ⚠️ hooks 미사용 | frontmatter hooks 추가 |
| Skills | 26개 | ⚠️ hooks 미사용 | frontmatter hooks 추가 |
| Commands | 18개 | ✅ 정상 | **유지 (Skills로 대체 불가)** |
| Instructions | 7개 | ⚠️ 플러그인 미지원 | bkit-rules skill로 통합 |
| Templates | 15개 | ✅ 정상 | 유지 |
| Hooks | 1개 (SessionStart) | ✅ 정상 | 유지 |

> ⚠️ **Commands 유지 결정**: Commands는 Skills와 목적이 다르므로 제거하지 않음.
> - Commands: 명시적 PDCA 프로세스 단계 (순서가 있는 워크플로우)
> - Skills: 배경 지식 및 자동 발견 대상 (순서 개념 없음)

---

## 3. 개선 계획

### 3.1 Phase 1: Skills Frontmatter Hooks 추가 (P0)

**목표:** 설계 문서 확인 및 PDCA 자동 적용

#### A. bkit-rules Skill 개선

```yaml
# skills/bkit-rules/SKILL.md
---
name: bkit-rules
description: |
  bkit 핵심 규칙. 모든 개발 작업에 자동 적용.

  Triggers: code, develop, implement, feature, bug, fix, create,
  코드, 개발, 구현, 기능, 버그, 수정, 만들어,
  コード, 開発, 実装, 代码, 开发, 实现

allowed-tools: Read, Glob, Grep, Write, Edit, Bash
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/scripts/pdca-pre-write.sh"
          timeout: 30
  PostToolUse:
    - matcher: "Write"
      hooks:
        - type: command
          command: "$CLAUDE_PROJECT_DIR/scripts/pdca-post-write.sh"
          timeout: 30
---

# bkit Core Rules (PDCA 자동 적용)

## 핵심 규칙

1. **설계 우선 (Design First)**
   - 기능 요청 → docs/02-design/ 확인 → 없으면 먼저 작성

2. **추측 금지 (No Guessing)**
   - 불확실하면 문서 확인 → 그래도 없으면 사용자에게 질문

3. **지속적 동기화**
   - 구현 완료 → Gap Analysis 제안

## PDCA 문서 위치

- Plan: docs/01-plan/features/{feature}.plan.md
- Design: docs/02-design/features/{feature}.design.md
- Analysis: docs/03-analysis/{feature}.analysis.md
- Report: docs/04-report/{feature}.report.md

## 자동 체크리스트

파일 작성 전:
- [ ] 관련 설계 문서 확인
- [ ] 기존 패턴 확인 (CLAUDE.md)

파일 작성 후:
- [ ] 설계-구현 일치 확인
- [ ] Gap Analysis 제안
```

#### B. pdca-pre-write.sh 스크립트

```bash
#!/bin/bash
# scripts/pdca-pre-write.sh
# PreToolUse (Write|Edit) hook

set -e

# stdin에서 JSON 입력 읽기
INPUT=$(cat)

# 파일 경로 추출
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')

# src/ 또는 lib/ 디렉토리의 파일인 경우만 체크
if [[ "$FILE_PATH" == src/* ]] || [[ "$FILE_PATH" == lib/* ]] || [[ "$FILE_PATH" == app/* ]]; then
    # 기능명 추출 (파일 경로에서 추론)
    FEATURE=$(basename "$(dirname "$FILE_PATH")" | sed 's/[^a-zA-Z0-9]/-/g')

    # 설계 문서 확인
    DESIGN_DOC="docs/02-design/features/${FEATURE}.design.md"

    if [ -f "$DESIGN_DOC" ]; then
        # 설계 문서가 있으면 additionalContext로 알림
        cat << EOF
{
  "decision": "allow",
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "additionalContext": "📋 PDCA 알림: ${DESIGN_DOC} 설계 문서가 존재합니다. 설계에 따라 구현하세요."
  }
}
EOF
    else
        # 설계 문서가 없으면 경고
        cat << EOF
{
  "decision": "allow",
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "additionalContext": "⚠️ PDCA 경고: ${DESIGN_DOC} 설계 문서가 없습니다. 설계를 먼저 작성하는 것을 권장합니다. /pdca-design 명령으로 생성할 수 있습니다."
  }
}
EOF
    fi
else
    # src/ 외의 파일은 그냥 통과
    echo '{"decision": "allow"}'
fi
```

#### C. pdca-post-write.sh 스크립트

```bash
#!/bin/bash
# scripts/pdca-post-write.sh
# PostToolUse (Write) hook

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')

# 소스 파일 작성 완료 시 Gap Analysis 제안
if [[ "$FILE_PATH" == src/* ]] || [[ "$FILE_PATH" == lib/* ]] || [[ "$FILE_PATH" == app/* ]]; then
    cat << EOF
{
  "suppressOutput": false,
  "hookSpecificOutput": {
    "additionalContext": "✅ 파일 작성 완료. 구현이 완료되면 /pdca-analyze 명령으로 Gap Analysis를 실행하여 설계와 구현의 일치를 확인할 수 있습니다."
  }
}
EOF
else
    echo '{}'
fi
```

### 3.2 Phase 2: Agents Frontmatter Hooks 추가 (P0)

**목표:** 에이전트 작업 완료 시 PDCA 체크리스트 자동 실행

#### A. gap-detector Agent 개선

```yaml
# agents/gap-detector.md
---
name: gap-detector
description: |
  설계-구현 Gap 분석 전문가.
  설계 문서와 실제 구현 코드를 비교하여 차이점을 분석합니다.
  Use proactively after implementation is complete.

  Triggers: gap analysis, 갭 분석, 비교, 차이, design vs implementation,
  ギャップ分析, 差距分析

model: opus
tools:
  - Read
  - Glob
  - Grep
skills:
  - analysis-patterns
  - pdca-methodology
hooks:
  Stop:
    - hooks:
      - type: command
        command: "$CLAUDE_PROJECT_DIR/scripts/gap-analysis-complete.sh"
        timeout: 30
---

You are an expert at comparing design documents with implementation code...
```

#### B. pdca-iterator Agent 개선

```yaml
# agents/pdca-iterator.md
---
name: pdca-iterator
description: |
  Evaluator-Optimizer 자동 반복 개선 전문가.
  설계와 구현의 Gap을 자동으로 수정합니다.
  Use proactively when auto-fix or iteration is requested.

  Triggers: iterate, optimize, auto-fix, 반복 개선, 자동 수정,
  イテレーション, 自動修正, 迭代优化

model: opus
tools:
  - Read
  - Glob
  - Grep
  - Write
  - Edit
skills:
  - evaluator-optimizer
  - pdca-methodology
hooks:
  Stop:
    - hooks:
      - type: command
        command: "$CLAUDE_PROJECT_DIR/scripts/iteration-complete.sh"
        timeout: 30
---

You are an expert at the Evaluator-Optimizer pattern...
```

#### C. design-validator Agent 개선

```yaml
# agents/design-validator.md
---
name: design-validator
description: |
  설계 문서 검증 전문가.
  설계 문서의 완전성과 일관성을 검증합니다.
  Use proactively after design document creation.

  Triggers: design validation, 설계 검증, document review,
  設計検証, 设计验证

model: sonnet
tools:
  - Read
  - Glob
  - Grep
skills:
  - document-standards
  - pdca-methodology
hooks:
  Stop:
    - hooks:
      - type: command
        command: "$CLAUDE_PROJECT_DIR/scripts/design-validated.sh"
        timeout: 30
---

You are an expert at validating design documents...
```

### 3.3 Phase 3: Semantic Matching 강화 (P1)

**목표:** 사용자가 에이전트 이름을 몰라도 자동 활성화

#### A. Description 패턴 표준화

모든 Agents와 Skills의 description에 다음 패턴 적용:

```yaml
description: |
  [역할 한 줄 설명]
  [상세 설명]
  Use proactively when [조건].

  Triggers: [영어], [한국어], [일본어], [중국어]

  Do NOT use for: [제외 조건]
```

#### B. Triggers 키워드 확장

| Agent | 현재 Triggers | 추가 Triggers |
|-------|--------------|--------------|
| starter-guide | beginner, 초보자 | 처음, 간단한, simple, easy, first time |
| bkend-expert | bkend, auth | 로그인, 회원가입, firebase, supabase |
| enterprise-expert | MSA, enterprise | 아키텍처, 마이크로서비스, K8s, terraform |
| gap-detector | gap analysis | 비교해, 확인해, 차이, 일치 |
| pipeline-guide | pipeline | 순서, 뭘 먼저, 어디서부터, where to start |

#### C. Skills 자동 발견 최적화

```yaml
# skills/bkit-rules/SKILL.md
---
name: bkit-rules
description: |
  bkit PDCA 핵심 규칙. 모든 개발 작업에 자동 적용됩니다.

  Use when: ANY development task including coding, implementing,
  creating features, fixing bugs, or refactoring.

  Triggers: code, develop, implement, create, build, fix, refactor,
  add feature, new feature, bug fix, 코드, 개발, 구현, 기능, 버그,
  コード, 開発, 代码, 开发

  Do NOT use for: documentation-only tasks, reading files, research.
---
```

### 3.4 Phase 4: Instructions 통합 (P1)

**문제:** 플러그인 구조에서 instructions/ 폴더 미지원

**해결:** bkit-rules Skill로 통합 + SessionStart Hook 강화

#### A. instructions/ 내용을 bkit-rules Skill에 통합

현재 7개 instruction 파일:
1. `pdca-rules.md` → bkit-rules skill에 통합
2. `auto-trigger-agents.md` → 각 agent description에 분산
3. `level-detection.md` → level-detection skill 생성
4. `code-quality-rules.md` → bkit-rules skill에 통합
5. `timeline-awareness.md` → document-standards skill에 통합
6. `zero-script-qa-rules.md` → zero-script-qa skill에 통합
7. `output-style-learning.md` → 제거 (기본 동작)

#### B. SessionStart Hook 강화

```bash
#!/bin/bash
# hooks/session-start.sh

cat << 'EOF'
{
  "additionalContext": "🎉 bkit Vibecoding Kit 활성화됨.

**PDCA 핵심 규칙 (자동 적용):**
- 기능 요청 → docs/02-design/ 확인 → 없으면 먼저 설계
- 추측 금지 → 문서 확인 → 질문
- 구현 완료 → Gap Analysis 제안

**도움이 필요하면:**
- /learn-claude-code - Claude Code 학습
- /pdca-status - PDCA 진행 상황
- /pipeline-start - 개발 파이프라인 시작

무엇을 도와드릴까요?"
}
EOF
```

### 3.5 Phase 5: Templates 개선 (P2)

**목표:** 자동 생성 템플릿 품질 향상

#### A. 템플릿 변수 확장

```markdown
# {feature} 설계 문서

> **생성일**: {date}
> **상태**: Draft
> **레벨**: {level}
> **관련 Plan**: docs/01-plan/features/{feature}.plan.md

## 1. 개요

### 1.1 목표
{goal}

### 1.2 범위
{scope}

## 2. 아키텍처

### 2.1 컴포넌트 구조
```

#### B. 템플릿 자동 선택

Level에 따른 템플릿 복잡도 자동 조절:
- Starter: 간소화된 템플릿
- Dynamic: 표준 템플릿
- Enterprise: 상세 템플릿

---

## 4. 구현 체크리스트

### Phase 1: Skills Frontmatter Hooks (1주)

```
□ scripts/pdca-pre-write.sh 생성
□ scripts/pdca-post-write.sh 생성
□ skills/bkit-rules/SKILL.md에 hooks 추가
□ skills/bkit-templates/SKILL.md에 hooks 추가
□ 로컬 테스트 (claude --plugin-dir ./bkit)
```

### Phase 2: Agents Frontmatter Hooks (1주)

```
□ scripts/gap-analysis-complete.sh 생성
□ scripts/iteration-complete.sh 생성
□ scripts/design-validated.sh 생성
□ agents/gap-detector.md에 hooks 추가
□ agents/pdca-iterator.md에 hooks 추가
□ agents/design-validator.md에 hooks 추가
□ 로컬 테스트
```

### Phase 3: Semantic Matching 강화 (3일)

```
□ 모든 agents description에 Triggers 확장
□ 모든 skills description에 Triggers 확장
□ WHEN + WHEN NOT 패턴 적용
□ 다국어 키워드 추가 (한/영/일/중)
```

### Phase 4: Instructions 통합 (2일)

```
□ bkit-rules skill에 instructions 통합
□ level-detection skill 생성
□ SessionStart hook 강화
□ instructions/ 파일 정리
```

### Phase 5: Templates 개선 (2일)

```
□ 템플릿 변수 확장
□ Level별 템플릿 분기
□ 자동 선택 로직 추가
```

---

## 5. 예상 결과

### 5.1 기능 복원 매트릭스

| 기능 | v1.1.4 | v1.2.0 | 방법 |
|------|--------|--------|------|
| 설계 문서 자동 확인 | ❌ | ✅ | Skills frontmatter hooks |
| 설계 없을 때 경고 | ❌ | ✅ | PreToolUse additionalContext |
| Gap Analysis 자동 제안 | ❌ | ✅ | PostToolUse hooks |
| 작업 완료 체크리스트 | ❌ | ✅ | Agents frontmatter Stop hooks |
| 에이전트 자동 활성화 | ⚠️ | ✅ | Semantic matching 강화 |
| PDCA 상태 추적 | ⚠️ | ✅ | hooks + .pdca-status.json |
| SessionStart 가이드 | ✅ | ✅ | 유지 |

### 5.2 사용자 경험 시나리오

**시나리오: 로그인 기능 개발**

```
사용자: "로그인 기능 만들어줘"

v1.1.4 (현재):
Claude: (바로 코드 작성 시작)

v1.2.0 (개선 후):
┌────────────────────────────────────────────────────────────┐
│ [bkit-rules skill 자동 활성화]                               │
│ [PreToolUse hook 실행]                                       │
│                                                              │
│ Claude: "docs/02-design/features/login.design.md 설계 문서가│
│ 없습니다. PDCA 원칙에 따라 먼저 설계 문서를 작성할까요?     │
│                                                              │
│ 1. 설계 문서 작성 후 구현                                    │
│ 2. 간단한 기능이라 바로 구현                                │
│                                                              │
│ 설계 문서가 있으면 더 정확한 구현이 가능합니다."             │
│                                                              │
│ [사용자 선택 후 진행]                                        │
│ [구현 완료 후 PostToolUse hook]                              │
│                                                              │
│ Claude: "구현이 완료되었습니다. Gap Analysis를 실행하여     │
│ 설계와 구현의 일치를 확인할까요?"                          │
└────────────────────────────────────────────────────────────┘
```

---

## 6. 위험 요소 및 완화 방안

### 6.1 위험 요소

| 위험 | 가능성 | 영향 | 완화 방안 |
|------|--------|------|----------|
| Skills frontmatter hooks 버그 | 중 | 높음 | 점진적 롤아웃, 폴백 준비 |
| Semantic matching 정확도 | 중 | 중 | 키워드 지속 확장, 피드백 수집 |
| Hook 타임아웃 | 낮음 | 중 | 스크립트 최적화, 타임아웃 설정 |
| 사용자 혼란 | 낮음 | 낮음 | 문서 업데이트, 점진적 도입 |

### 6.2 폴백 전략

Skills/Agents frontmatter hooks가 동작하지 않을 경우:
1. `type: "command"` 확인 (prompt 아닌지)
2. 스크립트 실행 권한 확인
3. 경로 변수 확인 (`$CLAUDE_PROJECT_DIR`)
4. 최악의 경우 SessionStart에서 모든 규칙 명시

---

## 7. 성공 기준

### 7.1 정량적 기준

| 지표 | 현재 | 목표 |
|------|------|------|
| 자동화 기능 동작률 | 20% | 90%+ |
| 설계 문서 생성 비율 | 측정 불가 | 70%+ |
| Gap Analysis 실행 비율 | 측정 불가 | 50%+ |
| 에이전트 자동 활성화 성공률 | 50% | 80%+ |

### 7.2 정성적 기준

- 사용자가 `/pdca-*` 명령어를 몰라도 PDCA 자동 적용
- 설계 없이 구현 시작하면 경고 표시
- 구현 완료 후 자연스럽게 검증 단계 안내
- 초보자도 Enterprise 수준의 문서 품질 달성

---

## 8. 다음 단계

1. **이 계획 승인 후 Phase 1 시작**
2. **Phase 1 완료 후 테스트 및 피드백 수집**
3. **Phase 2-5 순차 진행**
4. **v1.2.0 릴리즈 및 문서 업데이트**

---

## 부록 A: 참고 자료

### 공식 문서
- [Claude Code Skills](https://docs.anthropic.com/en/docs/claude-code/skills)
- [Claude Code Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [Claude Code Sub-agents](https://docs.anthropic.com/en/docs/claude-code/sub-agents)

### GitHub Issues
- [#13155 - Plugin prompt hooks ignored](https://github.com/anthropics/claude-code/issues/13155)
- [#13744 - PreToolUse exit 2 doesn't block Write/Edit](https://github.com/anthropics/claude-code/issues/13744)
- [#11544 - Hooks not loading](https://github.com/anthropics/claude-code/issues/11544)

### 버전 변경사항
- [CHANGELOG.md](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
- v2.1.9: PreToolUse additionalContext 추가
- v2.1.3: Hook 타임아웃 60초 → 10분

---

## 부록 B: 조사 원본 데이터

조사에 사용된 Agent ID (필요시 재개 가능):
- 설계 의도 분석: `a112f75`
- 현재 구현 분석: `aee608c`
- 공식 문서 조사: `aff40a0`
- GitHub 이슈 조사: `a36bb87`
- 버전 변경사항 조사: `a29afa7`

---

## 부록 C: Commands vs Skills 상세 비교

### C.1 아키텍처 결정: Commands 유지

**질문: Commands를 제거하고 Skills만 사용해도 되는가?**

**답변: ❌ 아니요. Commands와 Skills는 다른 목적을 가지므로 분리 유지해야 합니다.**

### C.2 상세 비교표

| 항목 | **Commands** | **Skills** |
|------|-------------|-----------|
| **파일 위치** | `.claude/commands/` | `.claude/skills/name/SKILL.md` |
| **발견 방식** | 명시적 (`/command-name`) | 자동 (Claude가 context 기반 선택) |
| **Context 로드** | **호출 시에만** | **항상 설명이 프리로드됨** |
| **고유 옵션** | `disable-model-invocation` | `hooks`, `context: fork`, `agent` |
| **순서 개념** | ✅ 있음 (PDCA 1→2→3→4) | ❌ 없음 (자동 발견) |
| **토큰 효율** | 높음 (필요할 때만) | 낮음 (항상 로드) |

### C.3 bkit에서의 역할 분담

```
┌─────────────────────────────────────────────────────────────────┐
│                    bkit 컴포넌트 역할 분담                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Commands (18개) - 명시적 프로세스 단계                         │
│  ├── PDCA 워크플로우:                                          │
│  │   /pdca-plan → /pdca-design → /pdca-analyze → /pdca-report │
│  ├── Pipeline 워크플로우:                                      │
│  │   /pipeline-start → /pipeline-next → /pipeline-status      │
│  ├── 초기화:                                                   │
│  │   /init-starter, /init-dynamic, /init-enterprise           │
│  └── 유틸리티:                                                 │
│      /learn-claude-code, /setup-claude-code, /zero-script-qa  │
│                                                                 │
│  Skills (26개) - 배경 지식 + 자동화                            │
│  ├── 핵심 지식:                                                │
│  │   pdca-methodology, document-standards, analysis-patterns  │
│  ├── 자동화 (frontmatter hooks):                               │
│  │   bkit-rules (PreToolUse, PostToolUse hooks)               │
│  ├── Pipeline 단계별 가이드:                                   │
│  │   phase-1-schema ~ phase-9-deployment                      │
│  └── 레벨별 전문 지식:                                         │
│      starter, dynamic, enterprise                              │
│                                                                 │
│  Agents (10개) - 전문가 역할                                   │
│  ├── 가이드: starter-guide, pipeline-guide, bkend-expert      │
│  ├── 검증: gap-detector, design-validator, code-analyzer      │
│  └── 자동화: pdca-iterator, report-generator, qa-monitor      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### C.4 Commands를 Skills로 변환하면 발생하는 문제

**예시: `/pdca-plan`을 Skill로 변환하는 경우**

```yaml
# ❌ 잘못된 접근: Command를 Skill로 변환
---
name: pdca-plan
description: |
  PDCA Plan 문서를 생성합니다.
  Triggers: plan, 계획, 計画
---
```

**문제점:**

1. **자동 발견 가능**: 사용자가 "계획"이라는 단어만 써도 자동 활성화될 수 있음
2. **순서 무시**: `/pdca-design`보다 먼저 실행해야 하는 순서가 무시됨
3. **Context 낭비**: 모든 대화에 설명이 로드됨
4. **의도 혼동**: "plan"이라는 단어가 다른 맥락에서도 매칭될 수 있음

### C.5 올바른 접근: Commands + Skills 조합

```
사용자: "로그인 기능 만들어줘"
                │
                ▼
     ┌──────────────────────┐
     │ Skills 자동 활성화:   │
     │ - bkit-rules         │ ← 배경 규칙 로드
     │ - phase-6-ui         │ ← UI 지식 로드
     └──────────────────────┘
                │
                ▼
     Claude: "설계 문서가 없습니다.
     /pdca-design 명령으로 먼저 설계를 작성할까요?"
                │
                ▼
     ┌──────────────────────┐
     │ Command 명시적 실행:  │
     │ /pdca-design login   │ ← 순서 있는 워크플로우
     └──────────────────────┘
```

### C.6 참고 자료

- [Claude Code Slash Commands 문서](https://code.claude.com/docs/en/slash-commands)
- [Claude Code Skills 문서](https://code.claude.com/docs/en/skills)
- [GitHub Issue #17578 - 문서 불일치 보고](https://github.com/anthropics/claude-code/issues/17578)
- [v2.1.3 CHANGELOG - Commands-Skills 병합](https://github.com/anthropics/claude-code/releases/tag/v2.1.3)

---

*문서 버전: 1.1*
*작성일: 2026-01-20*
*수정일: 2026-01-20*
*작성자: Claude (with User)*
*상태: Plan Phase - 승인 대기*
