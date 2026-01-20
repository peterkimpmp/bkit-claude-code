# Hooks Overview

> bkit에서 사용하는 4가지 Hook 이벤트 상세

## Hooks란?

Hooks는 **Claude Code의 특정 이벤트에 자동으로 실행되는 스크립트**입니다.
- Skills와 Agents의 frontmatter에 정의
- 이벤트 발생 시 shell script 실행
- 결과로 allow/block 결정 및 추가 컨텍스트 제공

## Hook 이벤트 종류

### 1. PreToolUse

**시점**: Claude가 도구를 사용하기 직전

**용도**:
- 위험한 작업 차단 (block)
- 작업 전 가이드라인 제공 (additionalContext)
- 조건부 허용

**입력 (stdin JSON)**:
```json
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.ts",
    "content": "..."
  }
}
```

**출력 (stdout JSON)**:
```json
{
  "decision": "allow|block",
  "reason": "차단 이유 (block 시)",
  "hookSpecificOutput": {
    "additionalContext": "Claude에게 전달할 컨텍스트"
  }
}
```

### 2. PostToolUse

**시점**: Claude가 도구 사용을 완료한 직후

**용도**:
- 작업 결과에 따른 후속 안내
- 다음 단계 제안
- 이슈 감지 및 알림

**입력**: PreToolUse와 동일

**출력**: PreToolUse와 동일 (보통 allow만 사용)

### 3. Stop

**시점**: Skill/Session 종료 시

**용도**:
- 작업 완료 요약
- 다음 단계 안내
- 결과 저장

**입력**: 없음 (또는 세션 컨텍스트)

**출력**:
```json
{
  "decision": "allow",
  "hookSpecificOutput": {
    "additionalContext": "종료 시 안내 메시지"
  }
}
```

### 4. SessionStart

**시점**: Claude Code 세션 시작 시

**용도**:
- 초기 환경 설정
- 사용자 인사 및 옵션 제시
- 프로젝트 레벨 감지

**정의 위치**: `settings.json` (skill frontmatter 아님)

```json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": ".claude/hooks/session-start.sh",
        "once": true
      }
    ]
  }
}
```

---

## Hook 정의 위치

### Skill Frontmatter

```yaml
# .claude/skills/bkit-rules/SKILL.md
---
name: bkit-rules
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      script: "./scripts/pdca-pre-write.sh"
  PostToolUse:
    - matcher: "Write"
      script: "./scripts/pdca-post-write.sh"
---
```

### Agent Frontmatter

```yaml
# .claude/agents/gap-detector.md
---
name: gap-detector
hooks:
  PostToolUse:
    - matcher: "Write"
      script: "./scripts/gap-detector-post.sh"
---
```

### settings.json

```json
{
  "hooks": {
    "SessionStart": [...],
    "PostToolUse": [...]
  }
}
```

---

## 이벤트별 매칭 현황

### PreToolUse

| Matcher | Skill/Agent | Script |
|---------|-------------|--------|
| `Write\|Edit` | bkit-rules | pdca-pre-write.sh |
| `Write\|Edit` | task-classification | task-classify.sh |
| `Write\|Edit` | phase-2-convention | phase2-convention-pre.sh |
| `Write` | design-validator | design-validator-pre.sh |
| `Bash` | zero-script-qa | qa-pre-bash.sh |
| `Bash` | phase-9-deployment | phase9-deploy-pre.sh |

### PostToolUse

| Matcher | Skill/Agent | Script |
|---------|-------------|--------|
| `Write` | bkit-rules | pdca-post-write.sh |
| `Write` | phase-5-design-system | phase5-design-post.sh |
| `Write` | phase-6-ui-integration | phase6-ui-post.sh |
| `Write` | gap-detector | gap-detector-post.sh |
| `Write` | qa-monitor | qa-monitor-post.sh |

### Stop

| Skill | Script |
|-------|--------|
| phase-4-api | phase4-api-stop.sh |
| phase-8-review | phase8-review-stop.sh |
| analysis-patterns | analysis-stop.sh |
| zero-script-qa | qa-stop.sh |
| development-pipeline | echo |

### SessionStart

| Source | Script |
|--------|--------|
| settings.json | session-start.sh |

---

## Hook Script 작성 규칙

### 표준 구조

```bash
#!/bin/bash
set -e

# stdin에서 JSON 입력 읽기
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# 조건 체크
if [[ 조건 ]]; then
    cat << EOF
{"decision": "block", "reason": "차단 이유"}
EOF
else
    cat << EOF
{"decision": "allow", "hookSpecificOutput": {"additionalContext": "안내 메시지"}}
EOF
fi
```

### 출력 규칙

1. 반드시 **valid JSON** 출력
2. `decision`: `"allow"` 또는 `"block"`
3. `block` 시 `reason` 필수
4. `additionalContext`는 Claude에게 전달됨

---

## 관련 문서

- [[../scripts/_scripts-overview]] - Script 상세
- [[../skills/_skills-overview]] - Skill 상세
- [[../../triggers/trigger-matrix]] - 트리거 매트릭스
- [[../../triggers/priority-rules]] - 우선순위 규칙
