# bkit Hooks 리팩토링 계획 v2

> **작성일**: 2026-01-19
> **수정일**: 2026-01-19 (additionalContext 활용 전략 추가)
> **목적**: Hooks 시스템 안정화 및 bkit 설계 의도 유지
> **관련 문서**:
> - [HOOKS-FIX-PLAN-2026-01-19.md](../03-analysis/HOOKS-FIX-PLAN-2026-01-19.md)
> - [CLAUDE-CODE-HOOKS-ANALYSIS.md](../03-analysis/CLAUDE-CODE-HOOKS-ANALYSIS.md)
> - [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks)

---

## 0. 핵심 발견 (v2 업데이트)

### additionalContext 지원 현황 (v2.1.9+)

| Hook Event | additionalContext | 위치 | 용도 |
|------------|:-----------------:|------|------|
| **PreToolUse** | ✅ | `hookSpecificOutput.additionalContext` | 도구 실행 전 컨텍스트 주입 |
| **PostToolUse** | ✅ | `hookSpecificOutput.additionalContext` | 도구 실행 후 컨텍스트 주입 |
| **SessionStart** | ✅ | `hookSpecificOutput.additionalContext` | 세션 시작 시 컨텍스트 주입 |
| **UserPromptSubmit** | ✅ | `hookSpecificOutput.additionalContext` | 프롬프트 제출 시 컨텍스트 주입 |
| **PermissionRequest** | ✅ | `hookSpecificOutput` | 권한 요청 시 |
| **Stop** | ❌ | - | additionalContext 미지원 |
| **SubagentStop** | ❌ | - | additionalContext 미지원 |
| **PreCompact** | ❌ | - | additionalContext 미지원 |

### 전략 변경

```
기존 계획: prompt type 제거 → skills/instructions로 대체 (자동화 약화)
새 계획:   prompt → command 전환 + additionalContext 활용 (Automation First 유지!)
```

---

## 1. 현재 상황 요약

### 1.1 발견된 문제점

| 우선순위 | 문제 | 영향 범위 | 해결책 |
|----------|------|-----------|--------|
| **Critical** | Plugin에서 `type: "prompt"` hooks 무시됨 ([#13155](https://github.com/anthropics/claude-code/issues/13155)) | `hooks/hooks.json` 전체 | command type + additionalContext |
| **Critical** | Stop hook JSON 형식 오류 (`decision: approve` 무효) | 4개 스크립트 | JSON 형식 수정 |
| **Medium** | `.claude/settings.json`의 prompt type 불안정 가능 | PreToolUse, PostToolUse, PreCompact | command type 전환 |
| **Info** | PreToolUse의 `decision`/`reason` deprecated | 모든 PreToolUse | `hookSpecificOutput.permissionDecision` 사용 |

### 1.2 bkit 설계 의도 (유지해야 할 핵심)

```
00-ARCHITECTURE.md 핵심 원칙:
┌─────────────────────────────────────────────────────────────────┐
│ "명령어를 모르는 개발자도 자연스럽게 '문서 중심 개발'과          │
│  '지속적 개선'을 실천할 수 있게 한다"                           │
│                                                                 │
│ 핵심: AI가 인간을 좋은 개발 습관으로 안내                       │
└─────────────────────────────────────────────────────────────────┘

3가지 핵심 철학:
1. Automation First - 사용자가 명령어 몰라도 PDCA 자동 적용
2. No Guessing - 모르면 문서 확인 → 없으면 사용자에게 질문
3. Docs = Code - 설계 먼저, 구현은 나중에
```

### 1.3 현재 Hooks 역할 분석

| Hook | 현재 역할 | bkit 목적 |
|------|----------|-----------|
| **SessionStart** | Welcome 메시지 + 옵션 제시 | 온보딩 자동화 |
| **PreToolUse** | Write/Edit 전 설계 문서 확인 요청 | Documentation First 강제 |
| **PostToolUse** | PDCA 진행 상태 추적 | 진행 상황 인식 |
| **Stop** | 작업 완료 전 체크리스트 | 품질 보장 |
| **SubagentStop** | 서브에이전트 완료 확인 | 작업 완료 보장 |
| **PreCompact** | 컨텍스트 압축 전 요약 | 정보 보존 |

---

## 2. 수정 전략 (v2 업데이트)

### 2.1 핵심 원칙

```
┌─────────────────────────────────────────────────────────────────┐
│ "Automation First를 유지하면서 안정성 확보"                      │
│                                                                 │
│ 1. prompt type → command type + additionalContext 전환          │
│ 2. hookSpecificOutput 구조 활용으로 PDCA 규칙 자동 주입          │
│ 3. 과도한 UX 간섭 없이 컨텍스트 기반 안내                        │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 전략 비교 (v2 업데이트)

| 전략 | 장점 | 단점 | 권장 |
|------|------|------|:----:|
| **A. 최소 수정** | 빠른 적용 | 근본 해결 안됨 | - |
| **B. prompt → command 전환만** | 안정성 확보 | 자동화 약화 | - |
| **C. hooks 제거 + skills 대체** | 간단 | Automation First 손실 | - |
| **D. command + additionalContext** | 안정성 + 자동화 유지 | 스크립트 작성 필요 | ✅ |

**권장: D (command type + additionalContext)**
- prompt type의 불안정성 해결
- additionalContext로 PDCA 규칙 자동 주입
- bkit의 Automation First 철학 완전 유지

---

## 3. 상세 수정 계획

### 3.1 Phase 1: Stop Hook JSON 형식 수정 (Critical)

**수정 대상**: 4개 파일

| 파일 | Before | After |
|------|--------|-------|
| `.claude/hooks/stop-hook.sh` | `{"decision": "approve"}` | `{"continue": false}` |
| `.claude/hooks/subagent-stop-hook.sh` | `{"decision": "approve"}` | `{"continue": false}` |
| `hooks/stop-hook.sh` | `{"decision": "approve"}` | `{"continue": false}` |
| `hooks/subagent-stop-hook.sh` | `{"decision": "approve"}` | `{"continue": false}` |

**수정 코드**:

```bash
#!/bin/bash
# stop-hook.sh - 수정 후

set -euo pipefail

# 기본값: Claude 정지 허용
# {"continue": false} 또는 빈 JSON
echo '{"continue": false}'
exit 0

# 만약 정지를 막고 싶다면:
# echo '{"continue": true, "stopReason": "테스트가 실행되지 않았습니다"}'
```

### 3.2 Phase 2: Plugin hooks.json - command + additionalContext (Critical)

**현재 문제**: `type: "prompt"` hooks가 플러그인에서 무시됨

**새 전략**: command type + additionalContext로 PDCA 규칙 자동 주입

**수정 후 `hooks/hooks.json`**:

```json
{
  "description": "bkit Vibecoding Kit hooks - command type with additionalContext",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/hooks/pre-write-hook.sh",
            "timeout": 5000
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/hooks/post-write-hook.sh",
            "timeout": 3000
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/hooks/stop-hook.sh"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/hooks/subagent-stop-hook.sh"
          }
        ]
      }
    ]
  }
}
```

### 3.2.1 새 스크립트: pre-write-hook.sh

```bash
#!/bin/bash
# bkit PreToolUse Hook - PDCA Check with additionalContext
set -euo pipefail

# stdin에서 hook context 읽기
input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // "unknown"')
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')

# src/* 파일에 쓰기 시 PDCA 규칙 주입
if [[ "$file_path" == src/* ]]; then
  cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "additionalContext": "[PDCA Check] Writing to src/. Before proceeding:\n1. Check if design doc exists in docs/02-design/\n2. For Feature/Major tasks, create design first\n3. Quick Fix/Minor → proceed directly\n\nApply task-classification skill rules."
  }
}
EOF
else
  # src/ 외 파일은 그냥 허용
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
fi

exit 0
```

### 3.2.2 새 스크립트: post-write-hook.sh

```bash
#!/bin/bash
# bkit PostToolUse Hook - PDCA Progress Tracking with additionalContext
set -euo pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')

# docs/01-plan/ 또는 docs/02-design/에 쓴 경우
if [[ "$file_path" == docs/01-plan/* ]] || [[ "$file_path" == docs/02-design/* ]]; then
  cat << 'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "[PDCA Progress] Document written. Consider:\n- Update .pdca-status.json if needed\n- Proceed to implementation if design complete"
  }
}
EOF
else
  echo '{}'
fi

exit 0
```

**유지되는 PDCA 자동화**:
- PreToolUse: src/* 쓰기 전 PDCA 규칙 컨텍스트 주입
- PostToolUse: 문서 작성 후 진행 상태 안내
- Stop: 작업 완료 확인

### 3.3 Phase 3: .claude/settings.json - command + additionalContext (Medium)

**전략**: 플러그인과 동일하게 command type + additionalContext 적용

```json
{
  "hooks": {
    "SessionStart": [
      {
        "once": true,
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/session-start.sh",
            "timeout": 5000
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/pre-write-hook.sh",
            "timeout": 5000
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/post-write-hook.sh",
            "timeout": 3000
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/stop-hook.sh"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/subagent-stop-hook.sh"
          }
        ]
      }
    ]
  }
}
```

**변경 사항**:
- PreToolUse: prompt → command + additionalContext
- PostToolUse: prompt → command + additionalContext
- PreCompact: 제거 (additionalContext 미지원, Claude 기본 동작 활용)

### 3.4 Phase 4: skills/bkit-rules 강화 (보완)

PreToolUse/PostToolUse hooks의 역할을 skill로 대체.

**수정 후 `skills/bkit-rules/SKILL.md`**:

```markdown
---
name: bkit-rules
description: |
  Core rules for bkit plugin. PDCA methodology, level detection,
  agent auto-triggering, and code quality standards.
  These rules are automatically applied to ensure consistent AI-native development.

  Triggers: bkit, PDCA, 개발, develop, implement, 기능, feature, 버그, bug,
  코드, code, 설계, design, 문서, document
---

# bkit Core Rules (Always Apply)

## 1. PDCA Documentation First

**Before writing code to src/*, ALWAYS check:**
- Does `docs/02-design/[feature].design.md` exist?
- If not, suggest: "Shall I create the design document first?"

**After implementation:**
- Suggest: "Implementation complete. Want to run Gap analysis?"

## 2. Task Classification

| Task Type | PDCA Level | Action |
|-----------|------------|--------|
| Quick Fix | Skip | Proceed directly |
| Minor Change | Lite | 3-line summary |
| Feature | Standard | Full design doc |
| Major Feature | Full | Plan + Design + Review |

## 3. No Guessing Rule

- Unclear requirements → Ask user
- Check docs first → Then ask
- Never assume or guess

## 4. Quality Standards

- No security vulnerabilities (OWASP Top 10)
- Type safety required
- Tests before deployment
```

### 3.5 Phase 5: instructions 활용 (대안)

`.claude/instructions/`는 항상 적용되는 규칙이므로 hooks보다 안정적.

**현재 instructions 구조 확인 필요**:
- pdca-rules.md → PDCA 규칙 강화
- auto-trigger.md → 에이전트 자동 활성화

---

## 4. 수정 파일 목록 (v2 업데이트)

### 4.1 Critical (즉시 수정)

| 파일 | 수정 내용 |
|------|----------|
| `.claude/hooks/stop-hook.sh` | JSON 형식: `{"continue": false}` |
| `.claude/hooks/subagent-stop-hook.sh` | JSON 형식: `{"continue": false}` |
| `hooks/stop-hook.sh` | JSON 형식: `{"continue": false}` |
| `hooks/subagent-stop-hook.sh` | JSON 형식: `{"continue": false}` |
| `hooks/hooks.json` | prompt → command + additionalContext |

### 4.2 신규 생성

| 파일 | 내용 |
|------|------|
| `hooks/pre-write-hook.sh` | PreToolUse PDCA 규칙 주입 (additionalContext) |
| `hooks/post-write-hook.sh` | PostToolUse PDCA 진행 추적 (additionalContext) |
| `.claude/hooks/pre-write-hook.sh` | 위와 동일 (.claude용) |
| `.claude/hooks/post-write-hook.sh` | 위와 동일 (.claude용) |

### 4.3 Medium (안정화)

| 파일 | 수정 내용 |
|------|----------|
| `.claude/settings.json` | prompt → command + additionalContext |

### 4.4 Optional (개선)

| 파일 | 수정 내용 |
|------|----------|
| `skills/bkit-rules/SKILL.md` | hooks와 연계된 규칙 보완 |
| `docs/02-BKIT-PLUGIN-DESIGN.md` | hooks 변경사항 반영 |

---

## 5. 수정 전후 비교 (v2 업데이트)

### 5.1 Hooks 구성 변화

```
Before (불안정):
┌─────────────────────────────────────────────────────┐
│ SessionStart (command) ✅                           │
│ PreToolUse (prompt) ⚠️ → 플러그인에서 무시          │
│ PostToolUse (prompt) ⚠️ → 플러그인에서 무시         │
│ Stop (command) ⚠️ → JSON 형식 오류                  │
│ SubagentStop (command) ⚠️ → JSON 형식 오류          │
│ PreCompact (prompt) ⚠️ → 플러그인에서 무시          │
└─────────────────────────────────────────────────────┘

After (v2 - 안정 + Automation First 유지):
┌─────────────────────────────────────────────────────┐
│ SessionStart (command) ✅                           │
│ PreToolUse (command + additionalContext) ✅         │
│   → PDCA 규칙 자동 주입                             │
│ PostToolUse (command + additionalContext) ✅        │
│   → PDCA 진행 상태 추적                             │
│ Stop (command) ✅ → JSON 형식 수정                  │
│ SubagentStop (command) ✅ → JSON 형식 수정          │
│                                                     │
│ [제거] PreCompact → additionalContext 미지원        │
└─────────────────────────────────────────────────────┘
```

### 5.2 bkit 핵심 기능 유지 방안 (v2)

| 원래 Hook 역할 | v1 계획 (skills 대체) | v2 계획 (additionalContext) |
|---------------|----------------------|----------------------------|
| PreToolUse: 설계 문서 확인 | skill로 대체 (약화) | command + additionalContext (유지) |
| PostToolUse: PDCA 진행 추적 | instructions (약화) | command + additionalContext (유지) |
| PreCompact: 컨텍스트 요약 | Claude 기본 동작 | Claude 기본 동작 (동일) |

### 5.3 Automation First 유지 비교

| 측면 | v1 계획 | v2 계획 |
|------|---------|---------|
| **PreToolUse 자동화** | ❌ skill 의존 (수동적) | ✅ additionalContext (자동) |
| **PostToolUse 자동화** | ❌ instructions (수동적) | ✅ additionalContext (자동) |
| **PDCA 규칙 강제** | ⚠️ skill 활성화 필요 | ✅ 모든 Write/Edit에 자동 적용 |
| **사용자 경험** | 자동화 약화 | 기존과 동일 |

---

## 6. 구현 순서

### Step 1: Stop Hook 수정 (30분)
```bash
# 4개 파일 JSON 형식 수정
.claude/hooks/stop-hook.sh
.claude/hooks/subagent-stop-hook.sh
hooks/stop-hook.sh
hooks/subagent-stop-hook.sh
```

### Step 2: Plugin hooks.json 정리 (15분)
```bash
# prompt type 제거, command만 유지
hooks/hooks.json
```

### Step 3: .claude/settings.json 정리 (15분)
```bash
# 불안정한 prompt hooks 제거
.claude/settings.json
```

### Step 4: skills/bkit-rules 강화 (30분)
```bash
# PDCA 규칙을 skill로 이전
skills/bkit-rules/SKILL.md
```

### Step 5: 테스트 (30분)
```bash
# 디버그 모드로 확인
claude --debug

# hooks 등록 확인
/hooks

# 기능 테스트
- SessionStart 정상 작동
- Stop hook JSON 파싱 정상
- PDCA 규칙 적용 확인
```

### Step 6: 문서 업데이트 (15분)
```bash
# 변경사항 반영
docs/02-BKIT-PLUGIN-DESIGN.md
docs/03-analysis/CLAUDE-CODE-HOOKS-ANALYSIS.md
```

---

## 7. 리스크 및 완화 방안

| 리스크 | 영향 | 완화 방안 |
|--------|------|----------|
| Hooks 제거로 자동화 약화 | 사용자 경험 저하 | skills/instructions로 보완 |
| skill 기반 규칙이 무시될 수 있음 | PDCA 미적용 | SessionStart에서 명시적 안내 |
| 기존 사용자 혼란 | 동작 변경 | CHANGELOG 문서화 |

---

## 8. 성공 기준

- [ ] `claude --debug`에서 hooks 오류 없음
- [ ] `/hooks` 명령에서 등록된 hooks 표시
- [ ] Stop hook 정상 작동 (정지 허용/차단)
- [ ] SessionStart에서 Welcome 메시지 표시
- [ ] PDCA 규칙이 skill을 통해 적용됨

---

## 9. 결론 (v2)

### 권장 접근 방식

```
┌─────────────────────────────────────────────────────────────────┐
│ "Automation First를 유지하면서 안정성 확보"                      │
│                                                                 │
│ 1. prompt type → command type 전환 (안정성)                     │
│ 2. additionalContext 활용으로 PDCA 규칙 자동 주입 (자동화 유지)  │
│ 3. hookSpecificOutput 구조로 표준화된 응답                      │
│ 4. Stop/SubagentStop JSON 형식 수정                             │
└─────────────────────────────────────────────────────────────────┘
```

### 다음 단계

1. 이 v2 계획에 대한 승인 요청
2. 승인 후 순차 구현
3. 테스트 완료 후 커밋

---

*이 문서는 Claude Code v2.1.12 기준으로 작성되었습니다.*
*additionalContext는 v2.1.9+에서 지원됩니다.*

**Sources:**
- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks)
- [GitHub Issue #13155](https://github.com/anthropics/claude-code/issues/13155)
