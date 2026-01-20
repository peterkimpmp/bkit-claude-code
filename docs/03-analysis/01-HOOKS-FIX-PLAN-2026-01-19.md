# Hooks 시스템 문제 분석 및 개선 계획

> **분석 대상 버전**: Claude Code v2.1.12 (현재)
> **이전 분석 버전**: Claude Code v2.1.7
> **작성일**: 2026-01-19
> **목적**: Hooks 시스템의 문제점 파악 및 수정 계획 수립

---

## 1. 조사 배경

### 1.1 문제 현상
- PreToolUse에서 stop hook이 과도하게 발생
- bkit 플러그인 및 `.claude/` 설정 사용 시 hooks 동작 이상

### 1.2 조사 범위
- Claude Code 공식 문서 (code.claude.com)
- GitHub Issues (anthropics/claude-code)
- 현재 구현 파일들:
  - `.claude/settings.json`
  - `.claude/hooks/` 스크립트들
  - `hooks/` 플러그인 hooks

---

## 2. 버전 변경사항 (v2.1.7 → v2.1.12)

| 버전 | 변경사항 |
|------|----------|
| v2.1.7 | Tool Hook 타임아웃 60초 → 10분 확대 |
| v2.1.9 | **PreToolUse hooks에서 `additionalContext` 반환 지원 추가** |
| v2.1.12 | 안정성 개선 (구체적 hooks 변경 없음) |

---

## 3. 발견된 심각한 문제점

### 3.1 [Critical] Plugin에서 `type: "prompt"` Hook 완전 무시

**GitHub Issue**: [#13155](https://github.com/anthropics/claude-code/issues/13155) (OPEN)

**문제**:
- 플러그인(`hooks/hooks.json`)에서 `type: "prompt"` hooks가 **등록 자체가 안됨**
- `type: "command"`만 정상 작동
- 에러 없이 조용히 무시됨 (silent failure)

**현재 구현에서 영향받는 부분**:

```
hooks/hooks.json:
├── PreToolUse (Write|Edit) → type: "prompt" (무시됨)
├── PostToolUse (Write) → type: "prompt" (무시됨)
├── PostToolUse (git commit) → type: "prompt" (무시됨)
├── PreCompact → type: "prompt" (무시됨)
├── Stop → type: "command" (정상)
└── SubagentStop → type: "command" (정상)
```

### 3.2 [Critical] Stop Hook JSON 응답 형식 오류

**현재 구현** (`.claude/hooks/stop-hook.sh`, `hooks/stop-hook.sh`):
```json
{"decision": "approve", "reason": "Task evaluation complete"}
```

**공식 문서 (Command Type)**:
```json
// Claude 정지 허용
{}

// Claude 정지 차단 (계속 작업 강제)
{"decision": "block", "reason": "Must provide reason"}
```

**문제점**:
- `"decision": "approve"`는 **공식 문서에 없는 값**

### 3.3 [Medium] PreToolUse Exit Code 2가 Write/Edit 차단 실패

**GitHub Issue**: [#13744](https://github.com/anthropics/claude-code/issues/13744)

---

## 4. 기타 알려진 이슈

| 이슈 | 내용 | 상태 | 영향 |
|------|------|------|------|
| [#11544](https://github.com/anthropics/claude-code/issues/11544) | settings.json hooks가 로드되지 않음 | Open | 높음 |
| [#17088](https://github.com/anthropics/claude-code/issues/17088) | PreToolUse 성공해도 "error" 라벨 표시 | Open | 낮음 |
| [#16047](https://github.com/anthropics/claude-code/issues/16047) | 2.5시간 후 hooks 중단 | Closed | 해결됨 |

---

## 5. 현재 구현 분석

### 5.1 `.claude/settings.json` Hooks

| Hook | Type | Matcher | 상태 |
|------|------|---------|------|
| SessionStart | command | - | 정상 |
| PreToolUse | **prompt** | Write\|Edit | 불안정 |
| PostToolUse | **prompt** | Write | 불안정 |
| PostToolUse | **prompt** | Bash(git commit *) | 불안정 |
| Stop | command | - | JSON 형식 오류 |
| SubagentStop | command | - | JSON 형식 오류 |
| PreCompact | **prompt** | auto | 불안정 |

### 5.2 `hooks/hooks.json` (플러그인)

| Hook | Type | Matcher | 상태 |
|------|------|---------|------|
| PreToolUse | **prompt** | Write\|Edit | 무시됨 (#13155) |
| PostToolUse | **prompt** | Write | 무시됨 (#13155) |
| PostToolUse | **prompt** | git commit | 무시됨 (#13155) |
| Stop | command | - | JSON 형식 오류 |
| SubagentStop | command | - | JSON 형식 오류 |
| PreCompact | **prompt** | auto | 무시됨 (#13155) |

---

## 6. 개선 계획

### 6.1 즉시 수정 필요 (Critical)

#### 6.1.1 Stop Hook JSON 형식 수정

**Before**:
```bash
echo '{"decision": "approve", "reason": "Task complete"}'
```

**After**:
```bash
# 정지 허용 시
echo '{"continue": false}'

# 정지 차단 시
echo '{"continue": true, "stopReason": "테스트가 실행되지 않았습니다"}'
```

#### 6.1.2 플러그인 prompt type → command type 변환

모든 `type: "prompt"` hooks를 `type: "command"`로 변환

### 6.2 안정성 개선 (Medium)

- `.claude/settings.json`의 prompt type도 command type으로 변환 권장
- 경로를 `$VAR` 대신 `${VAR}` 형식으로 통일

---

## 7. 수정 파일 목록

| 파일 | 수정 내용 | 우선순위 |
|------|----------|----------|
| `.claude/hooks/stop-hook.sh` | JSON 형식 수정 | Critical |
| `.claude/hooks/subagent-stop-hook.sh` | JSON 형식 수정 | Critical |
| `hooks/stop-hook.sh` | JSON 형식 수정 | Critical |
| `hooks/subagent-stop-hook.sh` | JSON 형식 수정 | Critical |
| `hooks/hooks.json` | prompt → command 변환 | Critical |
| `.claude/settings.json` | prompt → command 변환 | Medium |

---

## 8. 참고 자료

### 공식 문서
- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks)

### GitHub Issues
- [#13155 - Plugin prompt hooks ignored](https://github.com/anthropics/claude-code/issues/13155)
- [#13744 - PreToolUse exit 2 doesn't block Write/Edit](https://github.com/anthropics/claude-code/issues/13744)
- [#11544 - Hooks not loading](https://github.com/anthropics/claude-code/issues/11544)
- [#17088 - PreToolUse error label](https://github.com/anthropics/claude-code/issues/17088)

---

## 9. 결론

### 핵심 문제 요약

1. **플러그인에서 `type: "prompt"` hooks가 완전히 무시됨** (#13155)
2. **Stop hook JSON 형식이 잘못됨** - `{"decision": "approve"}`는 공식 문서에 없음
3. **PreToolUse exit 2가 Write/Edit를 차단하지 못함** (#13744)

### 권장 조치

1. 모든 prompt type hooks를 command type으로 변환
2. Stop hook JSON 형식을 공식 문서에 맞게 수정
3. 절대 경로 및 `${VAR}` 형식 사용
4. 정기적인 hooks.log 파일 크기 모니터링

---

*이 문서는 Claude Code v2.1.12 기준으로 작성되었습니다.*
